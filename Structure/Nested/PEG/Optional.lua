local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Nested.PEG.Optional : Sisyphus2.Structure.Nested.PEG.Base
---@field InnerPattern Sisyphus2.Structure.Nested.PEG.Base
local Optional = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Optional", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local Decompose = function(self, Canonical)
	local Decomposed = self.InnerPattern:Decompose(Canonical)^-1
	return Decomposed
end;

---@param self Sisyphus2.Structure.Nested.PEG.Optional
Optional.Initialize = function(_, self, InnerPattern)
	assert(type(InnerPattern) ~= "string")
	self.InnerPattern = InnerPattern
	self.Decompose = Decompose
end;

Optional.Copy = function(self)
	local New = Optional(self.InnerPattern:Copy())
	return New
end;

Optional.ToString = function(self)
	return tostring(self.InnerPattern) .."?"
end;

return Optional
