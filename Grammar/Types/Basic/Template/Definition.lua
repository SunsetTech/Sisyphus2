local Import = require"Toolbox.Import"
local Tools = require"Moonrise.Tools"

local Structure = require"Sisyphus2.Structure"

local Aliasable = Structure.Aliasable
local Template = Structure.Template

local PEG = Structure.Nested.PEG

local Interpreter = require"Sisyphus2.Interpreter"
local Syntax = Interpreter.Objects.Syntax
local Parse = Interpreter.Objects.Construct

local Definition = {}

--Constructs the syntax for capturing arguments to the template
function Definition.Arguments(Parameters)
	local ArgumentPatterns = {}

	--for Index, Parameter in pairs(Parameters) do
	for Index = 1, #Parameters do
		local Parameter = Parameters[Index]
		ArgumentPatterns[Index] = Parse.AliasableType(Parameter.Specifier.Target:Decompose(true))
	end

	local New = Parse.ArgumentList(ArgumentPatterns)
	return New
end



--Parses the template grammar for the newly defined template
function Definition.Finisher(Basetype, Name, Parameters, GeneratedTypes)
	local New = function(Body)
		local New = Interpreter.Generate.Namespace.Template(
				Template.Definition(
					Basetype,
					Aliasable.Type.Definition(
						Syntax.Tokens{
							PEG.Optional(
								PEG.Pattern(Name.Name)
							),
							Definition.Arguments(Parameters),
						},
						Interpreter.Execution.Invoker(Name, Parameters, Body)
					)
				),
				Name
			)
		return 
			New,
			GeneratedTypes
	end

	return New
end

function Definition.GenerateVariables(Parameters)
	local Variables = Template.Namespace()
	local GeneratedTypes = Aliasable.Namespace()

	--for Index, Parameter in pairs(Parameters) do
	for Index = 1, #Parameters do
		local Parameter = Parameters[Index]
		if Parameter.Specifier.GeneratedTypes then
			GeneratedTypes = GeneratedTypes + Parameter.Specifier.GeneratedTypes
		end
		Variables.Children:Add(
			Parameter.Name, Template.Definition(
				Parameter.Specifier.Target,
				Aliasable.Type.Definition(
					PEG.Pattern(Parameter.Name),
					Interpreter.Execution.NamedFunction("Get[".. Parameter.Name .."]", Interpreter.Generate.Argument.Resolver(Parameter.Name))
				)
			)
		);
	end

	return Variables, GeneratedTypes
end

function Definition.Generate(Name, Parameters, Basetype, Environment) --Creates a pattern that grabs an invocation of Basetype and then uses it to construct a template definition
	local CurrentGrammar = Environment.Grammar

	local Variables, GeneratedTypes = Definition.GenerateVariables(Parameters)
	local VariablesNamespace = Template.Namespace()
	VariablesNamespace.Children.Entries:Add("Variables", Variables)
	local DefinitionGrammar = Template.Grammar(
		Aliasable.Grammar(
			CurrentGrammar.InitialPattern,
			CurrentGrammar.AliasableTypes + GeneratedTypes,
			CurrentGrammar.BasicTypes,
			CurrentGrammar.Syntax,
			CurrentGrammar.Information
		),
		VariablesNamespace + Definition.Finisher(Basetype, Name, Parameters, GeneratedTypes)( --Recursion
			Interpreter.Execution.RecursiveUnfixed()
		)
	)
	DefinitionGrammar = DefinitionGrammar/"Aliasable.Grammar"
	DefinitionGrammar.InitialPattern = PEG.Apply( --Edit the initial pattern to match Basetype
		Parse.Centered(
			Parse.AliasableType(Basetype:Decompose(true))
		), --The returns matching the type, either values or a resolvable representing the unfinished transform
		Definition.Finisher(Basetype, Name, Parameters, GeneratedTypes)
	)

	return DefinitionGrammar
end

return Definition
