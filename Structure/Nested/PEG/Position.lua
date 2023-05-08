local Vlpeg = require"Sisyphus_Old.Vlpeg"
local OOP = require"Moonrise.OOP"

local Position = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Position", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

Position.Decompose = function(self, Canonical)
	local Decomposed = Vlpeg.Position()
	return Decomposed
end;

Position.Copy = function(self)
	local New = Position()
	return New
end;

return Position
