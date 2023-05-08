local lpeg = require"lpeg"
local CanonicalName = require"Sisyphus2.Structure.CanonicalName"

local OOP = require"Moonrise.OOP"

local Sibling = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Variable.Sibling", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local Decompose = function(self, Canonical)
	return lpeg.V(
		CanonicalName(self.Target, Canonical.Namespace):Decompose()
	)
end;

local Copy = function(self)
	return Sibling(self.Target)
end;

Sibling.Initialize = function(_, self, Target)
	self.Target = Target
	self.Decompose = Decompose
	self.Copy = Copy
end;

Sibling.ToString = function(self)
	return "^".. self.Target
end;

return Sibling
