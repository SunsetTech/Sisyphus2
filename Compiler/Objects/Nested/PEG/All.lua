local OOP = require"Moonrise.OOP"

local All = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.All", {
		require"Sisyphus2.Compiler.Object"
	}
)

function All:Initialize(Instance, InnerPattern)
	Instance.InnerPattern = InnerPattern
end

function All:Decompose(Canonical)
	return self.InnerPattern(Canonical)^0
end

function All:Copy()
	return All(-self.InnerPattern)
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
