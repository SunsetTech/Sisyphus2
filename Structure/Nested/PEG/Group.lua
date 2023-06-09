local Vlpeg = require"Sisyphus2.Vlpeg"
local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Nested.PEG.Group : Sisyphus2.Structure.Nested.PEG.Base
---@field Name string
---@field InnerPattern Sisyphus2.Structure.Nested.PEG.Base
local Group = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Group", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local function Decompose(self, Canonical)
	local Decomposed = Vlpeg.Group(self.InnerPattern:Decompose(Canonical), self.Name)
	return Decomposed
end

---@param Instance Sisyphus2.Structure.Nested.PEG.Group
function Group:Initialize(Instance, InnerPattern, Name)
	Instance.InnerPattern = InnerPattern
	Instance.Name = Name
	Instance.Decompose = Decompose
end

function Group:Copy()
	local New = Group(self.InnerPattern:Copy(), self.Name)
	return New
end

function Group:ToString()
	return "[".. (tostring(self.Name) or "?") .."=".. tostring(self.InnerPattern) .."]"
end

return Group
---TODO finish
--[[local Tools = require"Moonrise.Tools"
local Import = require"Moonrise.Import"

local Vlpeg = Import.Module.Relative"Vlpeg"
local Object = Import.Module.Relative"Object"

return Object(
	"Nested.PEG.Group", {
		Construct = function(self, InnerPattern, Name)
			--Tools.Error.CallerAssert(type(InnerPattern) ~= "string", "huh")
			self.Name = Name
			self.InnerPattern = InnerPattern
		end;

		Decompose = function(self, Canonical)
			return Vlpeg.Group(self.InnerPattern(Canonical), self.Name)
		end;
		
		Copy = function(self)
			return -self.InnerPattern, self.Name
		end;

		ToString = function(self)
			return "[".. (tostring(self.Name) or "?") .."=".. tostring(self.InnerPattern) .."]"
		end;
	}
)]]
