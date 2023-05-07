local lpeg = require"lpeg"
local CanonicalName = require"Sisyphus2.Structure.CanonicalName"

local OOP = require"Moonrise.OOP"

local Sibling = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Variable.Sibling", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

Sibling.Initialize = function(_, self, Target)
	self.Target = Target
end;

Sibling.Decompose = function(self, Canonical)
	return lpeg.V(
		CanonicalName(self.Target, Canonical.Namespace)()
	)
end;

Sibling.Copy = function(self)
	return Sibling(self.Target)
end;

Sibling.ToString = function(self)
	return "^".. self.Target
end;

return Sibling
