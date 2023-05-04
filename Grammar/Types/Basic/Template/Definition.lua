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

local Definition = {}

---Constructs the syntax for capturing arguments to the template
function Definition.Arguments(Parameters)
	local ArgumentPatterns = {}

	for Index, Parameter in pairs(Parameters) do
		ArgumentPatterns[Index] = Construct.AliasableType(Parameter.Specifier.Target:Invert()())
	end

	return Construct.ArgumentList(ArgumentPatterns)
end

function Definition.Invoker(Parameters, Body) --This is where we can construct the return object
	return function(Environment, ...)
		local Arguments = {...}
		local OldValues = {}
		
		--for Index, Parameter in pairs(Parameters) do
		for Index = 1,#Parameters do
			local Parameter = Parameters[Index]
			Environment.Variables[Parameter.Name] = Arguments[Index]
			OldValues[Parameter.Name] = Environment.Variables[Parameter.Name]
		end
		
		local Returns = {Body(Environment)}
		
		for Index = 1,#Parameters do
			local Parameter = Parameters[Index]
			Environment.Variables[Parameter.Name] = OldValues[Parameter.Name]
		end
		
		return table.unpack(Returns)
	end
end

--Constructs the template grammar for the newly defined template
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
								PEG.Optional(PEG.Pattern(Name.Name)),
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
	return Compiler.Transform.Incomplete(
		{...},
		function(...)
			return ...
		end
	)
end

function Definition.GenerateVariables(Parameters)
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

	DefinitionGrammar.InitialPattern = PEG.Apply( --Edit the initial pattern to match Basetype
		PEG.Apply(
			Construct.Centered(
				Construct.AliasableType(Basetype:Invert()())
			) , --The returns matching the type, either values or a resolvable representing the unfinished transform
			Definition.Return
		),
		Definition.Finish(Basetype, Name, Parameters, GeneratedTypes)
	)

	return DefinitionGrammar
end

return Definition
