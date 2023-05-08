local Vlpeg = require"Sisyphus2.Vlpeg"
local OOP = require"Moonrise.OOP"

local Set = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Set", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local Decompose = function(self)
	local Decomposed = Vlpeg.Set(self.Characters)
	return Decomposed
end;

Set.Initialize = function(_, self, Characters)
	self.Characters = Characters
	self.Decompose = Decompose
end;

Set.Copy = function(self)
	local New = Set(self.Characters)
	return New
end;

Set.ToString = function(self)
	return '['.. self.Characters:gsub("\t","\\t") ..']'
end;

return Set
