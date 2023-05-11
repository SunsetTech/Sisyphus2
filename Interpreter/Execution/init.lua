local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local OOP = require"Moonrise.OOP"

local Vlpeg = require"Sisyphus2.Vlpeg"

local Execution = {}

Execution.NamedFunction = require"Sisyphus2.Interpreter.Execution.NamedFunction"
Execution.Resolvable = require"Sisyphus2.Interpreter.Execution.Resolvable"
Execution.Lazy = require"Sisyphus2.Interpreter.Execution.Lazy"
Execution.Recursive = require"Sisyphus2.Interpreter.Execution.Recursive"
Execution.Variable = require"Sisyphus2.Interpreter.Execution.Variable"
Execution.Incomplete = require"Sisyphus2.Interpreter.Execution.Incomplete"

function Execution.ResolveArgument(Argument)
	while OOP.Reflection.Type.Of(Execution.Lazy, Argument) do
		Argument = Argument()
	end
	
	return Argument
end

function Execution.IsResolvable(Arguments, Index)
	local Argument = Arguments[Index]
	return OOP.Reflection.Type.Of(Execution.Resolvable, Argument)
end

function Execution.SetVariable(Environment, Parameters, Index, Arguments)
	local Parameter = Parameters[Index]
	Environment.Variables[Parameter.Name] = Arguments[Index]
	Tools.Debug.Format"Set variable %s to %s"(Parameter.Name, Arguments[Index])
end

function Execution.Invoker(Parameters, Body) --NOTE not sure we can fix this NYI 
	local New = function(...) --TODO make onesided. also figure out why Environment is stored in the args table
		local Arguments = {...}
		local Environment = {Body = Body; Variables = {}}
		Tools.Debug.Format"Invoking %s"(Body)
		Tools.Debug.Push()
		
		--for Index, Parameter in pairs(Parameters) do
		if #Parameters > 1 then
			for Index = 1,#Parameters do
				Execution.SetVariable(Environment, Parameters, Index, Arguments)
			end
		else
			Execution.SetVariable(Environment, Parameters, 1, Arguments)
		end
		
		local Returns = Body(Environment)
		Tools.Debug.Pop()
		Tools.Debug.Format"Returning %s from %s"(Returns, Body)
		return Returns
	end
	Tools.Debug.Format"Created invoker_%s for %s"(New, Body)
	return New
end

local function ArgumentsToString(Arguments)
	local Parts = {}
	--for k,v in pairs(Arguments) do
	for Index = 1, #Arguments do
		local v = Arguments[Index]
		table.insert(Parts, tostring(v))
	end
	return table.concat(Parts, ", ")
end

Execution.Freeze = function(Function, Arguments)
	Tools.Debug.Format"Checking %s(%s) for frozen elements"(Function, ArgumentsToString(Arguments))
	Tools.Debug.Push()
	local Incomplete = false
	if #Arguments > 1 then
		for Index = 1, #Arguments do
			Incomplete = not Incomplete and Execution.IsResolvable(Arguments, Index) or Incomplete
		end
	else
		Incomplete = Execution.IsResolvable(Arguments, 1)
	end
	
	local Return
	Tools.Debug.Pop()
	if Incomplete then
		Return = Execution.Incomplete(Arguments, Function)
		Tools.Debug.Format"Found frozen elements for %s(%s), froze into %s"(Function,ArgumentsToString(Arguments),Return)
	else
		Return = Function(table.unpack(Arguments)) --no incomplete arguments, simply apply and return
		Tools.Debug.Format"No frozen elements for %s(%s), called and got %s"(Function, ArgumentsToString(Arguments), Return)
	end
	return Return
end;

Execution.Completable = function(Pattern, Function)
	--[[
		Helper function to define completable transformations.
		If any of the captured values from Pattern are of type "incomplete transform"
		the return value is also an incomplete transform that when called
		attempts to resolve all incomplete arguments, and then return the application of Function over all arguments
	]]
	local New = (Vlpeg.Constant(Function) * Vlpeg.Table(Pattern)) / Execution.Freeze
	return New
end;

return Execution
