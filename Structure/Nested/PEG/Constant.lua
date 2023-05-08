local Vlpeg = require"Sisyphus2.Vlpeg"
local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Nested.PEG.Constant : Sisyphus2.Structure.Nested.PEG.Base
---@field Value any
local Constant = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Constant", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local function Decompose(self, Canonical)
	local Decomposed = Vlpeg.Constant(self.Value)
	return Decomposed
end

local function Copy(self)
	local New = Constant(self.Value)
	return New
end

function Constant:Initialize(Instance, Value)
	Instance.Value = Value
	Instance.Decompose = Decompose
	Instance.Copy = Copy
end

return Constant
--[[local Vlpeg = require"Sisyphus_Old.Vlpeg"
local Import = require"Moonrise.Import"

local Object = Import.Module.Relative"Object"

return Object(
	"Nested.PEG.Constant", {
		Construct = function(self, Value)
			self.Value = Value
		end;
		
		Decompose = function(self, Canonical)
			local t = Vlpeg.Constant(self.Value)
			return t
		end;
		
		Copy = function(self)
			return self.Value
		end;
	}
)]]
