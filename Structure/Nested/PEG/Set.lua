local Vlpeg = require"Sisyphus2.Vlpeg"
local OOP = require"Moonrise.OOP"

local Set = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Set", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local Decompose = function(self)
	return Vlpeg.Set(self.Characters)
end;

Set.Initialize = function(_, self, Characters)
	self.Characters = Characters
	self.Decompose = Decompose
end;

Set.Copy = function(self)
	return Set(self.Characters)
end;

Set.ToString = function(self)
	return '['.. self.Characters:gsub("\t","\\t") ..']'
end;

return Set
