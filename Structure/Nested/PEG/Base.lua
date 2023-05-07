local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Nested.PEG.Base : Sisyphus2.Structure.Object
local Base = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Base", {
		require"Sisyphus2.Structure.Object"
	}
)

return Base
