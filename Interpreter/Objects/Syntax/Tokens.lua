
local Import = require"Toolbox.Import"
local Structure = require"Sisyphus2.Structure"
local Pattern = Import.Module.Relative"Pattern"

local OOP = require"Moonrise.OOP"

local Tokens = OOP.Declarator.Shortcuts(
	"Nested.PEG.Syntax.Tokens", {
		require"Sisyphus2.Structure.Object"
	}
)

Tokens.Initialize = function(_, self, Patterns, _Patterns)
	self.Patterns = _Patterns or Structure.Array("Nested.PEG", Patterns)
	self.Decompose = Tokens.Decompose
	self.Copy = Tokens.Copy
	self.ToString = Tokens.ToString
end;

Tokens.Decompose = function(self, Canonical)
	return Pattern.Syntax.Tokens(unpack(self.Patterns(Canonical)))
end;

Tokens.Copy = function(self)
	return Tokens(nil, (-self.Patterns))
end;

Tokens.ToString = function(self)
	local Strings = {}
	for _, Item in pairs(self.Patterns.Items) do
		table.insert(Strings, tostring(Item))
	end
	return table.concat(Strings, " ")
end;

return Tokens
