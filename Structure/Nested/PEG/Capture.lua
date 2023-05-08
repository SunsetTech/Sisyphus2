local lpeg = require"lpeg"
local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Nested.PEG.Capture:Sisyphus2.Structure.Nested.PEG.Base
---@field SubPattern Sisyphus2.Structure.Nested.PEG.Base
local Capture = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Capture", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local function Decompose(self, Canonical)
	local Decomposed = lpeg.C(self.SubPattern:Decompose(Canonical))
	return Decomposed
end

local function Copy(self)
	local New = Capture(self.SubPattern:Copy())
	return New
end

---@param Instance Sisyphus2.Structure.Nested.PEG.Capture
function Capture:Initialize(Instance, SubPattern)
	Instance.SubPattern = SubPattern
	Instance.Decompose = Decompose
	Instance.Copy = Copy
end

function Capture:ToString()
	return "(".. tostring(self.SubPattern) ..")"
end

return Capture
--[[local lpeg = require"lpeg"
local Import = require"Moonrise.Import"

local Object = Import.Module.Relative"Object"

return Object(
	"Nested.PEG.Capture", {
		Construct = function(self, SubPattern)
			self.SubPattern = SubPattern
		end;
		
		Decompose = function(self, Canonical)
			return lpeg.C(self.SubPattern(Canonical))
		end;
		
		Copy = function(self)
			return -self.SubPattern
		end;

		ToString = function(self)
			return "(".. tostring(self.SubPattern) ..")"
		end;
	}
)]]
