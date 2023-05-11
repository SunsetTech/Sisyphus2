local OOP = require"Moonrise.OOP"
local Tools = require"Moonrise.Tools"

Variable = OOP.Declarator.Shortcuts(
	"Sisyphus2.Interpreter.Execution.Variable", {
		require"Sisyphus2.Interpreter.Execution.Resolvable"
	}
)

function Variable:__tostring()
	return "Variable[".. tostring(self.Location) .."]"
end

function Variable:Initialize(Instance, Location)
	Instance.Location = Location
	Tools.Debug.Format"Created %s"(Instance)
end

function Variable:__call(Environment)
	return Environment.Variables[self.Location]
end

return Variable