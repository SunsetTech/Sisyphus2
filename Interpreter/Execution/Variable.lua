local OOP = require"Moonrise.OOP"
local Tools = require"Moonrise.Tools"

local Box = require"Sisyphus2.Interpreter.Execution.Box"

local Variable = OOP.Declarator.Shortcuts(
	"Variable", {
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
	assert(Environment.Variables[self.Location] ~= nil)
	return Box("Unknown", Environment.Variables[self.Location])
end

return Variable
