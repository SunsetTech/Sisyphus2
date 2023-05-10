local Execution = require"Sisyphus2.Interpreter.Execution"

local Argument = {}

local __call = function(self, Environment)
	return Environment.Variables[self.Location]
end

local MT = {__call=__call}

function Argument.Resolver(Location)
	local New = function()
		--[[local New = Execution.Resolvable(
			setmetatable({Location=Location},MT)
		)
		return New]]
		return Execution.Variable(Location)
	end
	return New
end

return Argument
