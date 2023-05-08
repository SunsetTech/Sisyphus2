local Flat = require"Sisyphus2.Structure.Flat"
local OOP = require"Moonrise.OOP"

local Rule = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.Rule", {
		require"Sisyphus2.Structure.Object"
	}
)

function Rule:Initialize(Instance, Pattern)
	Instance.Pattern = Pattern
	Instance.Decompose = Rule.Decompose
end

function Rule:Decompose(Canonical)
	local Name = Canonical and Canonical:Decompose() or 1
	local Decomposed = Flat.Grammar()
	--[[{
		[Name] = self.Pattern(Canonical);
	}]]
	Decomposed:SetRule(Name, self.Pattern:Decompose(Canonical))
	return Decomposed
end

function Rule:Copy()
	local New = Rule(self.Pattern:Copy())
	return New
end

return Rule
