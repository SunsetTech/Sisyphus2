local Vlpeg = require"Sisyphus_Old.Vlpeg"
local OOP = require"Moonrise.OOP"

local Position = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Position", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

Position.Decompose = function(self, Canonical)
	return Vlpeg.Position()
end;

Position.Copy = function(self)
	return Position()
end;

return Position
