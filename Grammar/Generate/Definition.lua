local Import = require"Toolbox.Import"
local Functional = require"Toolbox.Tools.Functional"


local Compiler = require"Sisyphus2.Compiler"
local PEG = Compiler.Objects.Nested.PEG
local Aliasable = Compiler.Objects.Aliasable
local Template = Compiler.Objects.Template

local Argument = Import.Module.Sister"Argument"
local Type = Import.Module.Sister"Type"

local Parse = Import.Module.Relative"Objects.Parse"
local Static = Import.Module.Relative"Objects.Static"
local Syntax = Import.Module.Relative"Objects.Syntax"

local Definition = {}

function Definition.Boxer(...)
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
end

return Definition
