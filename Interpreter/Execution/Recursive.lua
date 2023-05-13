local Tools = require"Moonrise.Tools"
local OOP = require"Moonrise.OOP"
local Recursive = OOP.Declarator.Shortcuts(
	"Recursive", {
		require"Sisyphus2.Interpreter.Execution.Resolvable"
	}
)

function Recursive:Initialize(Instance, Variables)
	Instance.Variables = Variables
end

function Recursive:__call(Environment)
	if not Environment then
		Tools.Debug.PrintStack()
		error"This shouldn't happen"
	end
	--return self.Function(Environment.Body)
	local Body = Environment.Body
	Tools.Debug.Format"Recursing into %s"(Body)
	Tools.Debug.Push()
	local Result = Body{Body = Body, Variables = self.Variables}
	Tools.Debug.Pop()
	Tools.Debug.Format"Recursive %s got %s"(Body, Result)
	return Result
end

return Recursive
