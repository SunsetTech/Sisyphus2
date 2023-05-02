local OOP = require"Moonrise.OOP"
local Dematch = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Dematch", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

Dematch.Initialise = function(_, Instance, Pattern, Without)
	Instance.Pattern = Pattern
	Instance.Without = Without
end;

Dematch.Decompose = function(self, Canonical)
	assert(Canonical)
	return self.Pattern(Canonical) - self.Without(Canonical)
end;

Dematch.Copy = function(self)
	return Dematch(-self.Pattern, -self.Without)
end;

Dematch.ToString = function(self)
	return tostring(self.Pattern) .."-".. tostring(self.Without)
end;

return Dematch
--[[local Import = require"Moonrise.Import"
local lpeg = require"lpeg"

local Object = Import.Module.Relative"Object"

return Object(
	"Nested.PEG.Dematch", {
		Construct = function(self, Pattern, Without)
			self.Pattern = Pattern
			self.Without = Without
		end;

		Decompose = function(self, Canonical)
			assert(Canonical)
			return self.Pattern(Canonical) - self.Without(Canonical)
		end;
		
		Copy = function(self)
			return -self.Pattern, -self.Without
		end;

		ToString = function(self)
			return tostring(self.Pattern) .."-".. tostring(self.Without)
		end;
	}
)]]
