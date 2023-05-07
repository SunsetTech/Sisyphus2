local Import = require"Toolbox.Import"

local Structure = require"Sisyphus2.Structure"

local Aliasable = Structure.Aliasable
local Template = Structure.Template

local PEG = require"Sisyphus2.Structure.Nested.PEG"

local Objects = require"Sisyphus2.Interpreter.Objects"
local Syntax = Objects.Syntax
local Static = Objects.Static
local Parse = Objects.Construct
local Generate = require"Sisyphus2.Interpreter.Generate"
local Execution = require"Sisyphus2.Interpreter.Execution"

local Definition = {}

--Constructs the syntax for capturing arguments to the template
function Definition.Arguments(Parameters)
	local ArgumentPatterns = {}

	--for Index, Parameter in pairs(Parameters) do
	for Index = 1, #Parameters do
		local Parameter = Parameters[Index]
		ArgumentPatterns[Index] = Parse.AliasableType(Parameter.Specifier.Target:Invert()())
	end

	return Parse.ArgumentList(ArgumentPatterns)
end

function Definition.Invoker(Parameters, Body) 
	return function(Environment, ...)
		local Arguments = {...}
		local OldValues = {}
		
		--for Index, Parameter in pairs(Parameters) do
		for Index = 1,#Parameters do
			local Parameter = Parameters[Index]
			Environment.Variables[Parameter.Name] = Arguments[Index]
			OldValues[Parameter.Name] = Environment.Variables[Parameter.Name]
		end
		
		local LastBody = Environment.Body
		Environment.Body = Body
			local Returns = {Body(Environment)}
		Environment.Body = LastBody

		for Index = 1,#Parameters do
			local Parameter = Parameters[Index]
			Environment.Variables[Parameter.Name] = OldValues[Parameter.Name]
		end
		
		return table.unpack(Returns)
	end
end

--Parses the template grammar for the newly defined template
function Definition.Finish(Basetype, Name, Parameters, GeneratedTypes)
	return function(Body)
		return 
			Generate.Namespace.Template(
				Template.Definition(
					Basetype,
					Aliasable.Type.Definition(
						PEG.Sequence{
							Static.GetEnvironment,
							Syntax.Tokens{
								PEG.Optional(
									PEG.Pattern(Name.Name)
								),
								Definition.Arguments(Parameters),
							}
						},
						Definition.Invoker(Parameters, Body)
					)
				),
				Name
			),
			GeneratedTypes
	end
end

---fuck how do we even annotate this
---@param ... any
function Definition.Return(...) -- I forget why this was necessary
	return Execution.Incomplete(
		{...},
		function(...)
			return ...
		end
	)
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
					Generate.Argument.Resolver(Parameter.Name)
				)
			)
		);
	end

	return Variables, GeneratedTypes
end

function Definition.Generate(Name, Parameters, Basetype, Environment) --Creates a pattern that grabs an invocation of Basetype and then uses it to construct a template definition
	local CurrentGrammar = Environment.Grammar

	local Variables, GeneratedTypes = Definition.GenerateVariables(Parameters)
	local ArgumentPattern = Definition.Arguments(Parameters)
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
		VariablesNamespace + Definition.Finish(Basetype, Name, Parameters, GeneratedTypes)(
			function(...) 
				return Execution.Resolvable(
					function(Environment)
						return Environment.Body(Environment)
					end
				) 
			end
		)
	)
	DefinitionGrammar = DefinitionGrammar/"Aliasable.Grammar"
	DefinitionGrammar.InitialPattern = PEG.Apply( --Edit the initial pattern to match Basetype
		PEG.Apply(
			Parse.Centered(
				Parse.AliasableType(Basetype(true))
			) , --The returns matching the type, either values or a resolvable representing the unfinished transform
			Definition.Return
		),
		Definition.Finish(Basetype, Name, Parameters, GeneratedTypes)
	)

	return DefinitionGrammar
end

return Definition
