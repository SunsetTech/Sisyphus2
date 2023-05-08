local Vlpeg = require"Sisyphus2.Vlpeg"
local CanonicalName = require"Sisyphus2.Structure.CanonicalName"

local OOP = require"Moonrise.OOP"

local Child = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Variable.Child", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local Copy = function(self)
	local New = Child(self.Target)
	return New
end;

local Decompose = function(self, Canonical)
	local Decomposed = Vlpeg.Variable(
		CanonicalName(self.Target, Canonical):Decompose()
	)
	return Decomposed
end;

Child.Initialize = function(_, self, Target)
	assert(Target)
	self.Target = Target
	self.Copy = Copy
	self.Decompose = Decompose
end;

Child.ToString = function(self)
	return ">".. self.Target
end;

return Child
