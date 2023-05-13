local Tools = require"Moonrise.Tools"
local OOP = require"Moonrise.OOP"

local Lazy = require"Sisyphus2.Interpreter.Execution.Lazy"
local Struct = require"Sisyphus2.Interpreter.Execution.Struct"

local Invoker = OOP.Declarator.Shortcuts"Invoker"

function Invoker:Initialize(Instance, Typename, Parameters, Body)
	Instance.Typename = Typename
	Instance.Body = Body
	Instance.Parameters = Parameters
	Tools.Debug.Format"Created %s for %s"(Instance, Body)
end

local function ResolveArgument(Argument)
	Tools.Debug.Print"ResolveArgument"
	Tools.Debug.Push()
	while OOP.Reflection.Type.Of(Lazy, Argument) do
		Argument = Argument()
	end
	Tools.Debug.Pop()
	return Argument
end

local function SetVariable(Environment, Parameters, Index, Arguments)
	local Parameter = Parameters[Index]
	Environment.Variables[Parameter.Name] = ResolveArgument(Arguments[Index])
	Tools.Debug.Format"Set variable %s to %s"(Parameter.Name, Arguments[Index])
end

function Invoker:__call(...) 
	local Arguments = {...}
	local Environment = {Body = self.Body; Variables = {}}
	Tools.Debug.Format"Invoking %s"(self.Body)
	Tools.Debug.Push()
	
	--for Index, Parameter in pairs(Parameters) do
	if #self.Parameters > 1 then
		for Index = 1,#self.Parameters do
			SetVariable(Environment, self.Parameters, Index, Arguments)
		end
	else
		SetVariable(Environment, self.Parameters, 1, Arguments)
	end
	
	local Result = self.Body(Environment)
	Result = Struct(self.Typename:Decompose(), Result, Environment.Variables)
	Tools.Debug.Pop()
	Tools.Debug.Format"Returning %s from %s"(Result, self.Body)
	Tools.Debug.Format"Return struct %s"(Result)
	return Result
end

return Invoker
