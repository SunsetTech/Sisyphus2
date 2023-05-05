local Flat = require"Sisyphus2.Compiler.Objects.Flat"
local OOP = require"Moonrise.OOP"

local Rule = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.Rule", {
		require"Sisyphus2.Compiler.Object"
	}
)

function Rule:Initialize(Instance, Pattern)
	assert(Pattern)
	Instance.Pattern = Pattern
end

function Rule:Decompose(Canonical)
	local Name = Canonical and Canonical() or 1
	local Decomposed = Flat.Grammar()
	--[[{
		[Name] = self.Pattern(Canonical);
	}]]
	Decomposed:SetRule(Name, self.Pattern(Canonical))
	return Decomposed
end

function Rule:Copy()
	return Rule(self.Pattern:Copy())
end

return Rule
--[[local Import = require"Moonrise.Import"


local Flat = Import.Module.Relative"Flat"

return Object(
	"Nested.Rule", {
		Construct = function(self, Pattern)
			assert(Pattern ~= nil)
			self.Pattern = Pattern
		end;

		Decompose = function(self, Canonical)
			local Name = (
				Canonical
				and Canonical()
				or 1
			)
			return Flat.Grammar{
				[Name] = self.Pattern(Canonical);
			}
		end;
		Copy = function(self)
			return -self.Pattern
		end;
	}
)]]
