local Import = require"Toolbox.Import"
local Tools = require"Toolbox.Tools"

local Compiler = require"Sisyphus2.Compiler"
local CanonicalName = Compiler.Objects.CanonicalName

local Aliasable = Compiler.Objects.Aliasable
local Basic = Compiler.Objects.Basic
local Nested = Compiler.Objects.Nested
local Template = Compiler.Objects.Template

local PEG = Nested.PEG
local Variable = PEG.Variable

local Objects = Import.Module.Relative"Objects"
local Syntax = Objects.Syntax
local Static = Objects.Static
local Construct = Objects.Construct

local Vlpeg = require"Sisyphus2.Vlpeg"

local function CreateNamespaceFor(Entry, Canonical)
	local Namespace = Template.Namespace{
		[Canonical.Name] = Entry;
	}
	
	if Canonical.Namespace then
		return CreateNamespaceFor(
			Namespace,
			Canonical.Namespace
		)
	else
		return Namespace
	end
end

local function InvertName(Canonical)
	local Inverted = Compiler.Objects.CanonicalName(Canonical.Name)
	while(Canonical.Namespace) do
		Canonical = Canonical.Namespace
		Inverted = Compiler.Objects.CanonicalName(Canonical.Name, Inverted)
	end
	return Inverted
end

local function CreateArgumentsPattern(Parameters)
	local ArgumentPatterns = {}

	for Index, Parameter in pairs(Parameters) do
		ArgumentPatterns[Index] = Construct.AliasableType(InvertName(Parameter.Specifier.Target)())
	end

	return Construct.ArgumentList(ArgumentPatterns)
end

function DefinitionGenerator(Basetype, Name, Parameters, GeneratedTypes)
	return function(Finish)
		return 
			CreateNamespaceFor(
				Template.Definition(
					Basetype,
					Aliasable.Type.Definition(
						PEG.Sequence{
							Static.GetEnvironment,
							Syntax.Tokens{
								PEG.Optional(PEG.Pattern(Name.Name)),
								CreateArgumentsPattern(Parameters),
							}
						},
						function(Environment, ...)
							local Arguments = {...}
							local OldValues = {}
							for Index, Parameter in pairs(Parameters) do
								Environment.Variables[Parameter.Name] = Arguments[Index]
								OldValues[Parameter.Name] = Environment.Variables[Parameter.Name]
							end
							local Returns = {Finish(Environment)}
							for Name, Value in pairs(OldValues) do
								Environment.Variables[Name] = Value
							end
							return table.unpack(Returns)
						end
					)
				),
				Name
			),
			GeneratedTypes
	end
end

---fuck how do we even annotate this
---@param ... any
local function BoxReturns(...) -- I forget why this was necessary
	return Compiler.Transform.Incomplete(
		{...},
		function(...)
			return ...
		end
	)
end

local function CreateValueLookup(Location)
	return function()
		return Compiler.Transform.Resolvable(
			function(Environment)
				return Environment.Variables[Location]
			end
		)
	end
end

local function GetParameterTypes(Parameters)
	local Variables = Template.Namespace()
	local GeneratedTypes = Aliasable.Namespace()

	for Index, Parameter in pairs(Parameters) do
		if Parameter.Specifier.GeneratedTypes then
			GeneratedTypes = GeneratedTypes + Parameter.Specifier.GeneratedTypes
		end
		Variables.Children:Add(
			Parameter.Name, Template.Definition(
				Parameter.Specifier.Target,
				Aliasable.Type.Definition(
					PEG.Debug(PEG.Pattern(Parameter.Name)),
					CreateValueLookup(Parameter.Name)
				)
			)
		);
	end

	return Variables, GeneratedTypes
end

--
local function GenerateDefinitionGrammar(Name, Parameters, Basetype, Environment)
	local CurrentGrammar = Environment.Grammar

	local Variables, GeneratedTypes = GetParameterTypes(Parameters)
	local DefinitionGrammar = Template.Grammar(
		Aliasable.Grammar(
			CurrentGrammar.InitialPattern,
			CurrentGrammar.AliasableTypes + GeneratedTypes,
			CurrentGrammar.BasicTypes,
			CurrentGrammar.Syntax,
			CurrentGrammar.Information
		),
		Template.Namespace{
			Variables = Variables;
		}
	)
	DefinitionGrammar = DefinitionGrammar/"Aliasable.Grammar"

	local BasetypeRule = CanonicalName(InvertName(Basetype)(), CanonicalName"Types.Aliasable")()
	
	DefinitionGrammar.InitialPattern = PEG.Apply( --Edit the initial pattern to match Basetype
		PEG.Apply(
			PEG.Debug(
				Construct.Centered(
					Construct.AliasableType(InvertName(Basetype)())
				)
			), --The returns matching the type, either values or a resolvable representing the unfinished transform
			BoxReturns
		),
		DefinitionGenerator(Basetype, Name, Parameters, GeneratedTypes)
	)

	return DefinitionGrammar
end

local function LookupSpecifier(Namespace, Specifier)
	local Result = Namespace.Children.Entries[Specifier.Name]
	assert(Result ~= nil, "Couldn't find ".. Specifier())
	return 
		Specifier.Namespace
		and LookupSpecifier(Result, Specifier.Namespace)
		or Result
end

local function GetSpecifierCompleter(Specifier, Environment)
	local TypeDefinition = LookupSpecifier(Environment.Grammar.AliasableTypes, Specifier)
	Tools.Error.CallerAssert(TypeDefinition%"Aliasable.Type.Definition" or TypeDefinition%"Aliasable.Type.Incomplete")
	
	local CurrentGrammar = Environment.Grammar
	local ResumePattern = CurrentGrammar.InitialPattern
	
	if TypeDefinition%"Aliasable.Type.Definition.Incomplete" then
		CurrentGrammar.InitialPattern = PEG.Apply(
			PEG.Debug(TypeDefinition.Complete(Specifier)),
			function(...)
				CurrentGrammar.InitialPattern = ResumePattern
				return ...
			end
		)
	elseif TypeDefinition%"Aliasable.Type.Definition" then
		CurrentGrammar.InitialPattern = PEG.Debug(
			PEG.Apply(
				PEG.Pattern(0),
				function()
					CurrentGrammar.InitialPattern = ResumePattern
					return Specifier
				end
			)
		)
	end
	return CurrentGrammar
end

return Basic.Namespace{
	TypeSpecifier = Basic.Type.Definition(
		PEG.Apply(
			Construct.ChangeGrammar(
				PEG.Apply(
					PEG.Sequence{
						Variable.Canonical"Types.Basic.Name.Target",
						Static.GetEnvironment
					},
					GetSpecifierCompleter
				)
			),
			function(Target, GeneratedTypes)
				return {
					Target = Target;
					GeneratedTypes = GeneratedTypes;
				}
			end
		)
	);

	Parameter = Basic.Type.Definition(
		PEG.Table(
			Construct.ArgumentList{
				PEG.Group(
					Variable.Canonical"Types.Basic.Template.TypeSpecifier", "Specifier"
				),
				PEG.Group(
					Variable.Canonical"Types.Basic.Name.Part", "Name"
				)
			}
		)
	);

	Parameters = Basic.Type.Definition(
		PEG.Table(
			Construct.ArgumentArray(
				Variable.Canonical"Types.Basic.Template.Parameter"
			)
		)
	);

	Declaration = Basic.Type.Definition(
		Construct.ChangeGrammar(
			Construct.Invocation(
				"Template",
				Construct.ArgumentList{
					Variable.Canonical"Types.Basic.Name.Canonical",
					Variable.Canonical"Types.Basic.Template.Parameters",
					Variable.Canonical"Types.Basic.Name.Target"
				},
				GenerateDefinitionGrammar
			)
		)
	);
}
