local Import = require"Toolbox.Import"
local Tools = require"Toolbox.Tools"

local Structure = require"Sisyphus2.Structure"
local CanonicalName = Structure.CanonicalName
local PEG = Structure.Nested.PEG
local Basic = Structure.Basic
local Aliasable = Structure.Aliasable
local Template = Structure.Template
local Lookup = Structure.Lookup

local Objects = require"Sisyphus2.Interpreter.Objects"
local Incomplete = Objects.Incomplete
local Syntax = Objects.Syntax
local Parse = Objects.Parse
local Static = Objects.Static

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

function Type.Mask(Pattern, TypeArguments, Specify, ...) --What was this
	return Basic.Type.Definition(
		Syntax.Tokens{
			Pattern,
			Parse.ChangeGrammar(
				PEG.Apply(
					PEG.Sequence{
						Static.GetEnvironment,
						PEG.Stored"Basetype",
						TypeArguments or PEG.Pattern(0)
					},
					Specify
				)
			)
		},
		...
	)
end;
return Type
