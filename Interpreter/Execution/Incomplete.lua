local Tools = require"Moonrise.Tools"
local OOP = require"Moonrise.OOP"

local Lazy = require"Sisyphus2.Interpreter.Execution.Lazy"
local Recursive = require"Sisyphus2.Interpreter.Execution.Recursive"
local Variable = require"Sisyphus2.Interpreter.Execution.Variable"

local Incomplete = OOP.Declarator.Shortcuts( --TODO this is a hack
	"Sisyphus2.Interpreter.Execution.Incomplete", {
		require"Sisyphus2.Interpreter.Execution.Resolvable"
	}
)

function Incomplete:Initialize(Instance, Arguments, Function)
	Instance.Arguments = Arguments
	Instance.Function = Function
	Tools.Debug.Print("Created ".. tostring(Instance) .." for ".. tostring(Function))
end

local function ConvertToLazy(Argument, Environment, CurrentArguments)
	table.insert(
		CurrentArguments,
		(
			OOP.Reflection.Type.Of(Incomplete, Argument) 
			or OOP.Reflection.Type.Of(Variable, Argument)
			or OOP.Reflection.Type.Of(Recursive, Argument)
		)
		and Lazy(Argument, Environment)
		or Argument
	)
end

function Incomplete:__call(Environment)
	Tools.Debug.Format"Completing %s"(self.Function)
	Tools.Debug.Push()
	local CurrentArguments = {}
	if #self.Arguments > 1 then
		for Index = 1, #self.Arguments do 
			local Argument = self.Arguments[Index]
			ConvertToLazy(Argument, Environment, CurrentArguments)
		end
	else
		ConvertToLazy(self.Arguments[1], Environment, CurrentArguments)
	end
	
	local Return = self.Function(table.unpack(CurrentArguments))
	Tools.Debug.Pop()
	return Return
end

return Incomplete
