local OOP = require"Moonrise.OOP"
local Vlpeg = require"Sisyphus2.Vlpeg"

local Apply = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Apply", {
		require"Sisyphus2.Compiler.Object"
	}
)

function Apply:Initialize(Instance, Subpattern, Value)
	Instance.Subpattern = Subpattern
	Instance.Value = Value
end

function Apply:Decompose(Canonical)
	return Vlpeg.Apply(self.Subpattern(Canonical), self.Value)
end

function Apply:Copy()
	return Apply(-self.Subpattern, self.Value)
end

function Apply:ToString()
	return tostring(self.Subpattern) .."/".. tostring(self.Value)
end

return Apply

--[[local Import = require"Moonrise.Import"

local Vlpeg = Import.Module.Relative"Vlpeg"

local Object = Import.Module.Relative"Object"

return Object(
	"Nested.PEG.Apply", {
		Construct = function(self, SubPattern, Value)
			self.SubPattern = SubPattern
			self.Value = Value
		end;
		
		Decompose = function(self, Canonical)
			return Vlpeg.Apply(
				self.SubPattern(Canonical), 
				self.Value
			)
		end;

		Copy = function(self)
			return -self.SubPattern, self.Value
		end;

		ToString = function(self)
			return tostring(self.SubPattern) .."/".. tostring(self.Value)
		end;
	}
)]]
