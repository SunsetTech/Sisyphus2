local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Nested.PEG.Optional : Sisyphus2.Structure.Nested.PEG.Base
---@field InnerPattern Sisyphus2.Structure.Nested.PEG.Base
local Optional = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Optional", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local Decompose = function(self, Canonical)
	return self.InnerPattern(Canonical)^-1
end;

---@param self Sisyphus2.Structure.Nested.PEG.Optional
Optional.Initialize = function(_, self, InnerPattern)
	assert(type(InnerPattern) ~= "string")
	self.InnerPattern = InnerPattern
	self.Decompose = Decompose
end;

Optional.Copy = function(self)
	return Optional(self.InnerPattern:Copy())
end;

Optional.ToString = function(self)
	return tostring(self.InnerPattern) .."?"
end;

return Optional
