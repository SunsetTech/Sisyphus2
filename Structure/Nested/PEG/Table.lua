local Vlpeg = require"Sisyphus2.Vlpeg"
local OOP = require"Moonrise.OOP"

local Table = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Table", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

Table.Initialize = function(_,self, InnerPattern)
	self.InnerPattern = InnerPattern
end;

Table.Decompose = function(self, Canonical)
	return Vlpeg.Table(self.InnerPattern:Decompose(Canonical))
end;

Table.Copy = function(self)
	return Table(self.InnerPattern:Copy())
end;

Table.ToString = function(self)
	return "{".. tostring(self.InnerPattern) .."}"
end;

return Table
