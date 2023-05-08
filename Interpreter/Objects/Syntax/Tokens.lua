
local Import = require"Toolbox.Import"
local Structure = require"Sisyphus2.Structure"
local Pattern = Import.Module.Relative"Pattern"

local OOP = require"Moonrise.OOP"

local Tokens = OOP.Declarator.Shortcuts(
	"Nested.PEG.Syntax.Tokens", {
		require"Sisyphus2.Structure.Object"
	}
)

local Decompose = function(self, Canonical)
	local Decomposed = Pattern.Syntax.Tokens(unpack(self.Patterns:Decompose(Canonical)))
	return Decomposed
end;

local Copy = function(self)
	local New = Tokens(nil, self.Patterns:Copy())
	return New
end;

Tokens.Initialize = function(_, self, Patterns, _Patterns)
	self.Patterns = _Patterns or Structure.Array("Nested.PEG", Patterns)
	self.Decompose = Decompose
	self.Copy = Copy
	self.ToString = Tokens.ToString
end;

Tokens.ToString = function(self)
	local Strings = {}
	for _, Item in pairs(self.Patterns.Items) do
		table.insert(Strings, tostring(Item))
	end
	return table.concat(Strings, " ")
end;

return Tokens
