local Vlpeg = require"Sisyphus2.Vlpeg"
local OOP = require"Moonrise.OOP"

local Stored = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Stored", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)


Stored.Initialize = function(_, self, Name)
	self.Name = Name
end;

Stored.Decompose = function(self, Canonical)
	return Vlpeg.Stored(self.Name)
end;

Stored.Copy = function(self)
	return Stored(self.Name)
end;

return Stored
