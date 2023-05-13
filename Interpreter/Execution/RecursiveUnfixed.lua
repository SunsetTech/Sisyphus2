local OOP = require"Moonrise.OOP"
local Recursive = require"Sisyphus2.Interpreter.Execution.Recursive"

local RecursiveUnfixed = OOP.Declarator.Shortcuts(
	"RecursiveUnfixed", {
		require"Sisyphus2.Interpreter.Execution.Resolvable"
	}
)

function RecursiveUnfixed:__call(Environment)
	return Recursive(Environment.Variables)
end

return RecursiveUnfixed
