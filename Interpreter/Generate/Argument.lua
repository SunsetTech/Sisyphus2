local Import = require"Toolbox.Import"

local Structure = require"Sisyphus2.Structure"
local Nested = Structure.Nested
local PEG = Nested.PEG
local Aliasable = Structure.Aliasable
local Template = Structure.Template

local Parse = require"Sisyphus2.Interpreter.Objects.Parse"
local Execution = require"Sisyphus2.Interpreter.Execution"

local Argument = {}

function Argument.Resolver(Location)
	return function()
		return Execution.Resolvable(
			function(Environment)
				return Environment.Variables[Location]
			end
		)
	end
end

return Argument
