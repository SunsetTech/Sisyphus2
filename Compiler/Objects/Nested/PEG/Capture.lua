local lpeg = require"lpeg"
local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Compiler.Objects.Nested.PEG.Capture:Sisyphus2.Compiler.Objects.Nested.PEG.Base
---@field SubPattern Sisyphus2.Compiler.Objects.Nested.PEG.Base
local Capture = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Capture", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

---@param Instance Sisyphus2.Compiler.Objects.Nested.PEG.Capture
function Capture:Initialize(Instance, SubPattern)
	Instance.SubPattern = SubPattern
end

function Capture:Decompose(Canonical)
	return lpeg.C(self.SubPattern(Canonical))
end

function Capture:Copy()
	return Capture(-self.SubPattern)
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
