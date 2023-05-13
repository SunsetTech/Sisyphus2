local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local OOP = require"Moonrise.OOP"

local Vlpeg = require"Sisyphus2.Vlpeg"

local Execution = {}

Execution.NamedFunction = require"Sisyphus2.Interpreter.Execution.NamedFunction"
Execution.Resolvable = require"Sisyphus2.Interpreter.Execution.Resolvable"
Execution.Lazy = require"Sisyphus2.Interpreter.Execution.Lazy"
Execution.RecursiveUnfixed = require"Sisyphus2.Interpreter.Execution.RecursiveUnfixed"
Execution.Recursive = require"Sisyphus2.Interpreter.Execution.Recursive"
Execution.Variable = require"Sisyphus2.Interpreter.Execution.Variable"
Execution.Incomplete = require"Sisyphus2.Interpreter.Execution.Incomplete"
Execution.Invoker = require"Sisyphus2.Interpreter.Execution.Invoker"

function Execution.ResolveArgument(Argument)
	while OOP.Reflection.Type.Of(Execution.Lazy, Argument) do
		local Replacement = Argument()
		Tools.Debug.Format"ResolveArgument %s->%s"(Argument, Replacement)
		Argument = Replacement
	end
	return Argument
end

function Execution.IsResolvable(Arguments, Index)
	local Argument = Arguments[Index]
	return OOP.Reflection.Type.Of(Execution.Resolvable, Argument)
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
	--Tools.Debug.Format"?%s"(type(Function.Function)=="table" and Function.Function.Body)
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
		Tools.Debug.Print"No frozen"
		Tools.Debug.Push()
		Return = Function(table.unpack(Arguments)) --no incomplete arguments, simply apply and return
		Tools.Debug.Pop()
		Tools.Debug.Format"No frozen elements for %s(%s), called and got %s"(Function, ArgumentsToString(Arguments), Return)
	end
	return Return
end;

Execution.Completable = function(Pattern, Function)
	local New = (Vlpeg.Constant(Function) * Vlpeg.Table(Pattern)) / Execution.Freeze
	return New
end;

return Execution
