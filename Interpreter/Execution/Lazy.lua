local Tools = require"Moonrise.Tools"
local OOP = require"Moonrise.OOP"
local Recursive = require"Sisyphus2.Interpreter.Execution.Recursive"

Lazy = OOP.Declarator.Shortcuts(
	"Sisyphus2.Interpreter.Execution.Lazy", {
		require"Sisyphus2.Interpreter.Execution.Resolvable"
	}
)

function Lazy:Initialize(Instance, Inner, Environment)
	Instance.Inner = Inner
	Instance.Environment = Environment
end

function Lazy:__call()
	Tools.Debug.Format"Finishing %s"(self)
	Tools.Debug.Push()
	local Result = self.Inner(self.Environment)
	if (OOP.Reflection.Type.Of(Recursive, Result)) then --TODO this is a hack and I think wont work right in certain cases
		Result = Lazy(Result, self.Environment)
	end
	Tools.Debug.Pop()
	Tools.Debug.Format"%s -> %s"(self, Result)
	return Result
end

return Lazy