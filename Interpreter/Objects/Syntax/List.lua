local Import = require"Toolbox.Import"
local Structure = require"Sisyphus2.Structure"
local Pattern = Import.Module.Relative"Pattern"

local OOP = require"Moonrise.OOP"

local List = OOP.Declarator.Shortcuts(
	"Grammar.Objects.Syntax.List", {
		require"Sisyphus2.Structure.Object"
	}
)

List.Initialize = function(_, self, Patterns, Seperator)
	self.Patterns = Structure.Array("Nested.PEG", Patterns)
	self.Seperator = Seperator
	self.Decompose = List.Decompose
	self.Copy = List.Copy
end;

List.Decompose = function(self, Canonical)
	return Pattern.Syntax.Concatenate(self.Seperator(Canonical), table.unpack(self.Patterns(Canonical)))
end;

List.Copy = function(self)
	return List((-self.Patterns).Items, -self.Seperator)
end;

List.ToString = function(self)
	local Strings = {}
	for _, Item in pairs(self.Patterns.Items) do
		table.insert(Strings, tostring(Item))
	end
	return table.concat(Strings, tostring(self.Seperator))
end;

return List
