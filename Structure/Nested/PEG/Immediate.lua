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

local Decompose = function(self, Canonical)
	local Decomposed = Vlpeg.Immediate(
		self.InnerPattern:Decompose(Canonical), 
		self.Function
	)
	return Decomposed
end;

local Copy = function(self)
	local New = Immediate(self.InnerPattern:Copy(), self.Function)
	return New
end;

---@param Instance Sisyphus2.Structure.Nested.PEG.Immediate
function Immediate:Initialize(Instance, InnerPattern, Function)
	Instance.InnerPattern = InnerPattern
	Instance.Function = Function
	Instance.Copy = Copy
	Instance.Decompose = Decompose
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
