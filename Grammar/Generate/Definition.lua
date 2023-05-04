local Import = require"Toolbox.Import"

local Compiler = require"Sisyphus2.Compiler"
local CanonicalName = Compiler.Objects.CanonicalName

local Aliasable = Compiler.Objects.Aliasable
local Template = Compiler.Objects.Template

local PEG = require"Sisyphus2.Compiler.Objects.Nested.PEG"

local Argument = require"Sisyphus2.Grammar.Generate.Argument"

local Objects = Import.Module.Relative"Objects"
local Syntax = Objects.Syntax
local Static = Objects.Static
local Construct = Objects.Construct

local Definition = {}

function Definition.Returns(...) -- I forget why this was necessary
	return Compiler.Transform.Incomplete(
		{...},
		function(...)
			return ...
		end
	)
end

function Definition.Variables(Parameters)
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
					Argument.Resolver(Parameter.Name)
				)
			)
		);
	end

	return Variables, GeneratedTypes
end

function Definition.Grammar(Name, Parameters, Basetype, Environment)
	local CurrentGrammar = Environment.Grammar

	local Variables, GeneratedTypes = Definition.GetParameterTypes(Parameters)
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

	local BasetypeRule = CanonicalName(Basetype:Invert()(), CanonicalName"Types.Aliasable")()
	
	DefinitionGrammar.InitialPattern = PEG.Apply( --Edit the initial pattern to match Basetype
		PEG.Apply(
			Construct.Centered(
				Construct.AliasableType(Basetype:Invert()())
			) , --The returns matching the type, either values or a resolvable representing the unfinished transform
			Definition.Returns
		),
		Utils.DefinitionGenerator(Basetype, Name, Parameters, GeneratedTypes)
	)

	return DefinitionGrammar
end

--[[function Definition.Boxer(...)
	return Compiler.Transform.Incomplete(
		{...},
		Functional.Return
	)
end

function Definition.Invoker(Parameters, Invoke)
	return function(Environment, ...)
		local NewValues = {...}
		local OldValues = {}
		
		for Index, Parameter in pairs(Parameters) do
			Environment.Variables[Parameter.Name] = NewValues[Index]
			OldValues[Parameter.Name] = Environment.Variables[Parameter.Name]
		end
		
		local Returns = {Invoke(Environment)}
		
		for Name, Value in pairs(OldValues) do
			Environment.Variables[Name] = Value
		end
		
		return table.unpack(Returns)
	end
end

function Definition.Finisher(Basetype, Name, Parameters, GeneratedTypes)
	return function(Finish)
		return 
			Type.Namespace(
				Name,
				Template.Definition(
					Basetype,
					Aliasable.Type.Definition(
						PEG.Sequence{
							Static.GetEnvironment,
							Syntax.Tokens{
								PEG.Optional(PEG.Pattern(Name.Name)),
								Argument.Patterns(Parameters),
							}
						},
						Definition.Invoker(Parameters, Finish)
					)
				)
			),
			GeneratedTypes
	end
end

function Definition.Grammar(Name, Parameters, Basetype, Environment)
	local CurrentGrammar = Environment.Grammar
	--print("Parameters", #Parameters)
	local Variables, GeneratedTypes = Argument.Types(Parameters)
	
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
	)()
	
	local BasetypeRule = Parse.Aliasable(Basetype())
	
	DefinitionGrammar.InitialPattern = PEG.Apply(
		PEG.Apply(
			Parse.Centered(BasetypeRule),
			Definition.Boxer
		),
		Definition.Finisher(Basetype, Name, Parameters, GeneratedTypes)
	)
	
	return DefinitionGrammar
end]]

return Definition
