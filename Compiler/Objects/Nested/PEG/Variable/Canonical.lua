local lpeg = require"lpeg"

local OOP = require"Moonrise.OOP"

local Canonical = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Variable.Canonical", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

local Decompose = function(self)
	return lpeg.V(self.Target)
end;

Canonical.Initialize = function(_, self, Target)
	self.Target = Target
	self.Decompose = Decompose
end;


Canonical.Copy = function(self)
	return Canonical(self.Target)
end;

Canonical.ToString = function(self)
	return "#".. self.Target
end;

return Canonical
