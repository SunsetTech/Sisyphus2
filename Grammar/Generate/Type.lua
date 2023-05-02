local Import = require"Toolbox.Import"
local Tools = require"Toolbox.Tools"

local Compiler = require"Sisyphus2.Compiler"
local CanonicalName = Compiler.Objects.CanonicalName
local PEG = Compiler.Objects.Nested.PEG
local Basic = Compiler.Objects.Basic
local Aliasable = Compiler.Objects.Aliasable
local Template = Compiler.Objects.Template
local Lookup = Compiler.Lookup

local Incomplete = Import.Module.Relative"Objects.Incomplete"
local Syntax = Import.Module.Relative"Objects.Syntax"
local Parse = Import.Module.Relative"Objects.Parse"
local Static = Import.Module.Relative"Objects.Static"

local Type = {}

function Type.Namespace(Canonical, Entry)
	local Namespace = Template.Namespace{
		[Canonical.Name] = Entry;
	}
	
	if Canonical.Namespace then
		return Type.Namespace(
			Canonical.Namespace,
			Namespace
		)
	else
		return Namespace
	end
end

function Type.Fullname(Canonical, Specifier)
	--print(Specifier)
	return CanonicalName(
		Canonical.Name .."<".. Specifier.Target() ..">", 
		Canonical.Namespace
	)
end

function Type.Completer(Specifier, Environment) 
	local TypeDefinition = Lookup.AliasableType(Environment.Grammar.AliasableTypes, Specifier)
	Tools.Error.CallerAssert(TypeDefinition%"Aliasable.Type.Definition" or TypeDefinition%"Aliasable.Type.Incomplete")
	
	local CurrentGrammar = Environment.Grammar
	local ResumePattern = CurrentGrammar.InitialPattern
	
	if TypeDefinition%"Aliasable.Type.Definition.Incomplete" then
		CurrentGrammar.InitialPattern = PEG.Apply(
			TypeDefinition.Complete(Specifier),
			function(...)
				CurrentGrammar.InitialPattern = ResumePattern
				return ...
			end
		)
	elseif TypeDefinition%"Aliasable.Type.Definition" then
		CurrentGrammar.InitialPattern = PEG.Apply(
			PEG.Pattern(0),
			function()
				CurrentGrammar.InitialPattern = ResumePattern
				return Specifier
			end
		)
		
	end
	return CurrentGrammar
end

function Type.Generic(Pattern, TypeParameters, Specify, ...)
	return Incomplete(
		Pattern,
		function(Canonical)--Array<TypeSpecifier>
			return PEG.Apply(
				TypeParameters,
				function(...) -- Generate the match Specifier and the Added Types
					--print("aaa", ...)
					local TypeArguments = {...}
					local InstanceName = Type.Fullname(Canonical, ...)
					local GeneratedTypes = 
						Aliasable.Namespace()
						+ Type.Namespace(
							InstanceName,
							Specify(...)
						)
					
					for _, TypeArgument in pairs(TypeArguments) do
						if TypeArgument.GeneratedTypes then
							GeneratedTypes = GeneratedTypes + TypeArgument.GeneratedTypes
						end
					end
					
					return InstanceName, GeneratedTypes
				end
			)
		end,
		...
	)
end;

function Type.Mask(Pattern, TypeArguments, Specify, ...)
	return Basic.Type.Definition(
		Syntax.Tokens{
			Pattern,
			Parse.ChangeGrammar(
				PEG.Apply(
					PEG.Sequence{
						Static.GetEnvironment,
						PEG.Stored"Basetype",
						TypeParameters or PEG.Pattern(0)
					},
					Specify
				)
			)
		},
		...
	)
end;
return Type
