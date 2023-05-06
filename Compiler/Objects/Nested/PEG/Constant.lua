local Vlpeg = require"Sisyphus2.Vlpeg"
local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Compiler.Objects.Nested.PEG.Constant : Sisyphus2.Compiler.Objects.Nested.PEG.Base
---@field Value any
local Constant = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Constant", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

function Constant:Initialize(Instance, Value)
	Instance.Value = Value
	Instance.Decompose = Constant.Decompose
end

function Constant:Decompose(Canonical)
	return Vlpeg.Constant(self.Value)
end

function Constant:Copy()
	return Constant(self.Value)
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
