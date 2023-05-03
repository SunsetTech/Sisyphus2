local Tools = require"Moonrise.Tools"
local Vlpeg = require"Sisyphus2.Vlpeg"
local OOP = require"Moonrise.OOP"

local Range = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Range", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)


Range.Initialize = function(_, self, ...)
	self.Sets = {...}
end;

Range.Decompose = function(self)
	return Vlpeg.Range(table.unpack(self.Sets))
end;

Range.Copy = function(self)
	return Range(table.unpack(Tools.Table.Copy(self.Sets)))
end;

Range.ToString = function(self)
	local Strings = {}
	for _, Set in pairs(self.Sets) do
		table.insert(Strings, "\27[32m".. Set .."\27[0m")
	end
	return '"'.. table.concat(Strings,",") ..'"'
end;

return Range