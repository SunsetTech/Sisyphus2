local Import = require"Toolbox.Import"

local Compiler = require"Sisyphus2.Compiler"
local CanonicalName = Compiler.Objects.CanonicalName

local Aliasable = Compiler.Objects.Aliasable
local Template = Compiler.Objects.Template

local PEG = require"Sisyphus2.Compiler.Objects.Nested.PEG"

local Objects = Import.Module.Relative"Objects"
local Syntax = Objects.Syntax
local Static = Objects.Static
local Construct = Objects.Construct
local Generate = require"Sisyphus2.Grammar.Generate"

local Utils = {}

function Utils.InvertName(Canonical)
	local Inverted = Compiler.Objects.CanonicalName(Canonical.Name)
	while(Canonical.Namespace) do
		Canonical = Canonical.Namespace
		Inverted = Compiler.Objects.CanonicalName(Canonical.Name, Inverted)
	end
	return Inverted
end

function Utils.CreateArgumentsPattern(Parameters)
	local ArgumentPatterns = {}

	for Index, Parameter in pairs(Parameters) do
		ArgumentPatterns[Index] = Construct.AliasableType(Utils.InvertName(Parameter.Specifier.Target)())
	end

	return Construct.ArgumentList(ArgumentPatterns)
end

function Utils.DefinitionGenerator(Basetype, Name, Parameters, GeneratedTypes)
	return function(Finish)
		return 
			Generate.Namespace.Template(
				Template.Definition(
					Basetype,
					Aliasable.Type.Definition(
						PEG.Sequence{
							Static.GetEnvironment,
							Syntax.Tokens{
								PEG.Optional(PEG.Pattern(Name.Name)),
								Utils.CreateArgumentsPattern(Parameters),
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
function Utils.BoxReturns(...) -- I forget why this was necessary
	return Compiler.Transform.Incomplete(
		{...},
		function(...)
			return ...
		end
	)
end

function Utils.CreateValueLookup(Location)
	return function()
		return Compiler.Transform.Resolvable(
			function(Environment)
				return Environment.Variables[Location]
			end
		)
	end
end

function Utils.GetParameterTypes(Parameters)
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
					Utils.CreateValueLookup(Parameter.Name)
				)
			)
		);
	end

	return Variables, GeneratedTypes
end

--
function Utils.GenerateDefinitionGrammar(Name, Parameters, Basetype, Environment)
	local CurrentGrammar = Environment.Grammar

	local Variables, GeneratedTypes = Utils.GetParameterTypes(Parameters)
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

	local BasetypeRule = CanonicalName(Utils.InvertName(Basetype)(), CanonicalName"Types.Aliasable")()
	
	DefinitionGrammar.InitialPattern = PEG.Apply( --Edit the initial pattern to match Basetype
		PEG.Apply(
			PEG.Debug(
				Construct.Centered(
					Construct.AliasableType(Utils.InvertName(Basetype)())
				)
			), --The returns matching the type, either values or a resolvable representing the unfinished transform
			Utils.BoxReturns
		),
		Utils.DefinitionGenerator(Basetype, Name, Parameters, GeneratedTypes)
	)

	return DefinitionGrammar
end

return Utils
