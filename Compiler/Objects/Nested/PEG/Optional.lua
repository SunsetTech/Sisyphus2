local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Compiler.Objects.Nested.PEG.Optional : Sisyphus2.Compiler.Objects.Nested.PEG.Base
---@field InnerPattern Sisyphus2.Compiler.Objects.Nested.PEG.Base
local Optional = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Optional", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

---@param self Sisyphus2.Compiler.Objects.Nested.PEG.Optional
Optional.Initialize = function(_, self, InnerPattern)
	assert(type(InnerPattern) ~= "string")
	self.InnerPattern = InnerPattern
end;

Optional.Decompose = function(self, Canonical)
	return self.InnerPattern(Canonical)^-1
end;

Optional.Copy = function(self)
	return Optional(-self.InnerPattern)
end;

Optional.ToString = function(self)
	return tostring(self.InnerPattern) .."?"
end;

return Optional
