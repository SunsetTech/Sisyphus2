local OOP = require"Moonrise.OOP"

local Atleast = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Atleast", {
		require"Sisyphus2.Structure.Object"
	}
)

function Atleast:Initialize(Instance, Amount, InnerPattern)
	Instance.Amount = Amount
	Instance.InnerPattern = InnerPattern
	Instance.Decompose = Atleast.Decompose
end

function Atleast:Decompose(Canonical)
	local Decomposed = self.InnerPattern:Decompose(Canonical)^self.Amount
	return Decomposed
end

function Atleast:Copy()
	local New = Atleast(self.Amount, self.InnerPattern:Copy())
	return New
end

function Atleast:ToString()
	return tostring(self.InnerPattern) .."^".. self.Amount
end

return Atleast

--[[local Import = require"Moonrise.Import"

local Object = Import.Module.Relative"Structure.Object"

return Object(
	"Nested.PEG.Atleast", {
		Construct = function(self, Amount, InnerPattern)
			self.Amount = Amount
			self.InnerPattern = InnerPattern
		end;

		Decompose = function(self, Canonical)
			return self.InnerPattern(Canonical)^self.Amount
		end;

		Copy = function(self)
			return self.Amount, -self.InnerPattern
		end;

		ToString = function(self)
			return tostring(self.InnerPattern) .."^".. self.Amount
		end;
	}
)]]
