local Tools = require"Moonrise.Tools"
local OOP = require"Moonrise.OOP"
Recursive = OOP.Declarator.Shortcuts(
	"Sisyphus2.Interpreter.Execution.Recursive", {
		require"Sisyphus2.Interpreter.Execution.Resolvable"
	}
)

function Recursive:Initialize(Instance, Function)
	Instance.Function = Function
end

function Recursive:__call(Environment)
	if not Environment then
		Tools.Debug.PrintStack()
		error"This shouldn't happen"
	end
	return self.Function(Environment.Body)
end

return Recursive
