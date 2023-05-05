local OOP = require"Moonrise.OOP"

local Atleast = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Atleast", {
		require"Sisyphus2.Compiler.Object"
	}
)

function Atleast:Initialize(Instance, Amount, InnerPattern)
	Instance.Amount = Amount
	Instance.InnerPattern = InnerPattern
end

function Atleast:Decompose(Canonical)
	return self.InnerPattern(Canonical)^self.Amount
end

function Atleast:Copy()
	return Atleast(self.Amount, self.InnerPattern:Copy())
end

function Atleast:ToString()
	return tostring(self.InnerPattern) .."^".. self.Amount
end

return Atleast

--[[local Import = require"Moonrise.Import"

local Object = Import.Module.Relative"Compiler.Object"

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
