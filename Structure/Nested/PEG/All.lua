local OOP = require"Moonrise.OOP"

local All = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.All", {
		require"Sisyphus2.Structure.Object"
	}
)

local function Decompose(self, Canonical)
	local Decomposed = self.InnerPattern:Decompose(Canonical)^0
	return Decomposed
end

local function Copy(self)
	local New = All(self.InnerPattern:Copy())
	return New
end

function All:Initialize(Instance, InnerPattern)
	Instance.InnerPattern = InnerPattern
	Instance.Decompose = Decompose
	Instance.Copy = Copy
end

function All:ToString()
	return tostring(self.InnerPattern) .."^0"
end

return All

--[[local Import = require"Moonrise.Import"

local Object = Import.Module.Relative"Object"

return Object(
	"Nested.PEG.All", {
		Construct = function(self, InnerPattern)
			self.InnerPattern = InnerPattern
		end;

		Decompose = function(self, Canonical)
			return self.InnerPattern(Canonical)^0
		end;

		Copy = function(self)
			return -self.InnerPattern
		end;

		ToString = function(self)
			return tostring(self.InnerPattern) .."*"
		end;
	}
)]]
