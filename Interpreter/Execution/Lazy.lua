local Tools = require"Moonrise.Tools"
local OOP = require"Moonrise.OOP"
local Recursive = require"Sisyphus2.Interpreter.Execution.Recursive"

local Lazy = OOP.Declarator.Shortcuts(
	"Lazy", {
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
	if (OOP.Reflection.Type.Of(Recursive, Result)) then --TODO this is a hack and I think wont work right in certain cases. It's caused by the use of variables in the recursive call, causing the invoker function to show up in the frozen call tree
		local Replacement = Lazy(Result, self.Environment)
		Tools.Debug.Format"HACK %s->%s"(Result, Replacement)
		Result = Replacement
	end
	Tools.Debug.Pop()
	Tools.Debug.Format"%s -> %s"(self, Result)
	return Result
end

return Lazy
