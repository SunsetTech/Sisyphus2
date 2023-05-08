local OOP = require"Moonrise.OOP"
local Vlpeg = require"Sisyphus2.Vlpeg"

local Apply = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Apply", {
		require"Sisyphus2.Structure.Object"
	}
)

local function Decompose(self, Canonical)
	local Decomposed = Vlpeg.Apply(self.Subpattern:Decompose(Canonical), self.Value)
	return Decomposed
end

local function Copy(self)
	local New = Apply(self.Subpattern:Copy(), self.Value)
	return New
end

function Apply:Initialize(Instance, Subpattern, Value)
	Instance.Subpattern = Subpattern
	Instance.Value = Value
	Instance.Decompose = Decompose
	Instance.Copy = Copy
end

function Apply:ToString()
	return tostring(self.Subpattern) .."/".. tostring(self.Value)
end

return Apply
