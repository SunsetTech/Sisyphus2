local Execution = require"Sisyphus2.Interpreter.Execution"

local function __call(self)
	return Execution.Variable(self.Location)
end

local Argument = {}

function Argument.Resolver(Location)
	local New = setmetatable({Location = Location},{__call=__call})
	return New
end

return Argument
