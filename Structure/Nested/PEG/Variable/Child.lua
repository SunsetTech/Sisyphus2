local Vlpeg = require"Sisyphus2.Vlpeg"
local CanonicalName = require"Sisyphus2.Structure.CanonicalName"

local OOP = require"Moonrise.OOP"

local Child = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Variable.Child", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

Child.Initialize = function(_, self, Target)
	assert(Target)
	self.Target = Target
end;

Child.Decompose = function(self, Canonical)
	return Vlpeg.Variable(
		CanonicalName(self.Target, Canonical)()
	)
end;

Child.Copy = function(self)
	return Child(self.Target)
end;

Child.ToString = function(self)
	return ">".. self.Target
end;

return Child
