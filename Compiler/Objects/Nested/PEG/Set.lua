local Vlpeg = require"Sisyphus2.Vlpeg"
local OOP = require"Moonrise.OOP"

local Set = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Set", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

Set.Initialize = function(_, self, Characters)
	self.Characters = Characters
end;

Set.Decompose = function(self)
	return Vlpeg.Set(self.Characters)
end;

Set.Copy = function(self)
	return Set(self.Characters)
end;

Set.ToString = function(self)
	return '['.. self.Characters:gsub("\t","\\t") ..']'
end;

return Set