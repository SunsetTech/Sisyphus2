local Import = require"Toolbox.Import"
local Tools = require"Moonrise.Tools"

local Structure = require"Sisyphus2.Structure"

local Aliasable = Structure.Aliasable
local Template = Structure.Template

local PEG = require"Sisyphus2.Structure.Nested.PEG"

local Objects = require"Sisyphus2.Interpreter.Objects"
local Syntax = Objects.Syntax
local Static = require"Sisyphus2.Interpreter.Parse.Static"
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
		ArgumentPatterns[Index] = Parse.AliasableType(Parameter.Specifier.Target:Decompose(true))
	end

	local New = Parse.ArgumentList(ArgumentPatterns)
	return New
end



--Parses the template grammar for the newly defined template
function Definition.Finish(Basetype, Name, Parameters, GeneratedTypes)
	local New = function(Body)
		local New = Generate.Namespace.Template(
				Template.Definition(
					Basetype,
					Aliasable.Type.Definition(
						Syntax.Tokens{
							PEG.Optional(
								PEG.Pattern(Name.Name)
							),
							Definition.Arguments(Parameters),
						},
						Execution.NamedFunction(Name:Decompose(),  Execution.Invoker(Parameters, Body))
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

---fuck how do we even annotate this
local function Passthrough(...)
	local Args = {...}
	local Returns = {}
	for k,v in pairs(Args) do
		Returns[k] = Execution.ResolveArgument(v)
	end
	return table.unpack(Returns)
end
---@param ... any
function Definition.Return(...) -- I forget why this was necessary. Update: I've almost remembered. Update: it didnt seem to be actually necessary
	--[[local New = Execution.Incomplete( {...}, Execution.NamedFunction("Template.Passthrough", Passthrough))
	return New]]
	return ...
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
					Execution.NamedFunction("Get[".. Parameter.Name .."]", Generate.Argument.Resolver(Parameter.Name))
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
		VariablesNamespace + Definition.Finish(Basetype, Name, Parameters, GeneratedTypes)( --Recursion
			function(Environment) 
				--[[for K,V in pairs(Environment.Variables) do
					SavedVariables[K] = V
				end]]
				return Execution.Recursive(
					function(Body)
						--print("bbb", Body.Resolve.Function)
						Tools.Debug.Format"Recursing into %s"(Body)
						Tools.Debug.Push()
						local Result = Body{Body = Body, Variables = Environment.Variables}
						Tools.Debug.Pop()
						Tools.Debug.Format"Recursive %s got %s"(Body, Result)
						return Result
								--return "Lazy Evaluation NYI"--Body(Environment)
					end
				) 
			end
		)
	)
	DefinitionGrammar = DefinitionGrammar/"Aliasable.Grammar"
	DefinitionGrammar.InitialPattern = PEG.Apply( --Edit the initial pattern to match Basetype
		PEG.Apply(
			Parse.Centered(
				Parse.AliasableType(Basetype:Decompose(true))
			) , --The returns matching the type, either values or a resolvable representing the unfinished transform
			Definition.Return
		),
		Definition.Finish(Basetype, Name, Parameters, GeneratedTypes)
	)

	return DefinitionGrammar
end

return Definition
