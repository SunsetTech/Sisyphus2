local Vlpeg = require"Sisyphus2.Vlpeg"
local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Nested.PEG.Immediate : Sisyphus2.Structure.Nested.PEG.Base
---@field InnerPattern Sisyphus2.Structure.Nested.PEG.Base
---@field Function function
local Immediate = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Immediate", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

---@param Instance Sisyphus2.Structure.Nested.PEG.Immediate
function Immediate:Initialize(Instance, InnerPattern, Function)
	Instance.InnerPattern = InnerPattern
	Instance.Function = Function
end;

Immediate.Decompose = function(self, Canonical)
	return Vlpeg.Immediate(
		self.InnerPattern(Canonical), 
		self.Function
	)
end;

Immediate.Copy = function(self)
	return Immediate(-self.InnerPattern, self.Function)
end;

Immediate.ToString = function(self)
	return tostring(self.Function) .."(".. tostring(self.InnerPattern) ..")"
end;

return Immediate

--[[local Import = require"Moonrise.Import"

local Vlpeg = Import.Module.Relative"Vlpeg"

local Object = Import.Module.Relative"Object"

return Object(
	"Nested.PEG.Immediate", {
		Construct = function(self, InnerPattern, Function)
			self.InnerPattern = InnerPattern
			self.Function = Function
		end;

		Decompose = function(self, Canonical)
			return Vlpeg.Immediate(
				self.InnerPattern(Canonical), 
				self.Function
			)
		end;
		
		Copy = function(self)
			return -self.InnerPattern, self.Function
		end;

		ToString = function(self)
			return tostring(self.Function) .."(".. tostring(self.InnerPattern) ..")"
		end;
	}
)]]
