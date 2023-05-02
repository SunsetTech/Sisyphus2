local Vlpeg = require"Sisyphus2.Vlpeg"
local OOP = require"Moonrise.OOP"

local Table = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Table", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

Table.Initialize = function(_,self, InnerPattern)
	self.InnerPattern = InnerPattern
end;

Table.Decompose = function(self, Canonical)
	return Vlpeg.Table(self.InnerPattern(Canonical))
end;

Table.Copy = function(self)
	return Table(-self.InnerPattern)
end;

Table.ToString = function(self)
	return "{".. tostring(self.InnerPattern) .."}"
end;

return Table
