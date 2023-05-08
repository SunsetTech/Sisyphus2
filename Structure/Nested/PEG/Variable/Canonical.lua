local lpeg = require"lpeg"

local OOP = require"Moonrise.OOP"

local Canonical = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Variable.Canonical", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local Decompose = function(self)
	local Decomposed = lpeg.V(self.Target)
	return Decomposed
end;

Canonical.Initialize = function(_, self, Target)
	self.Target = Target
	self.Decompose = Decompose
end;


Canonical.Copy = function(self)
	local New = Canonical(self.Target)
	return New
end;

Canonical.ToString = function(self)
	return "#".. self.Target
end;

return Canonical
