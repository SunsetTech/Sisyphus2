--[[
local Import = require"Toolbox.Import"
local Compiler = require"Sisyphus2.Compiler"
local Pattern = Import.Module.Relative"Pattern"

local OOP = require"Moonrise.OOP"

local Tokens = OOP.Declarator.Shortcuts(
	"Sisyphus2.Grammar.Objects.Syntax.Tokens", {
		require"Sisyphus2.Compiler.Object"
	}
)

Tokens.Initialize = function(_, self, Patterns)
	self.Patterns = Compiler.Objects.Array("Nested.PEG", Patterns)
end;

Tokens.Decompose = function(self, Canonical)
	local v = Pattern.Syntax.Tokens(unpack(self.Patterns(Canonical)))
	assert(type(v) == "userdata")
	return v
end;

Tokens.Copy = function(self)
	return Tokens((-self.Patterns).Items)
end;

Tokens.ToString = function(self)
	local Strings = {}
	for _, Item in pairs(self.Patterns.Items) do
		table.insert(Strings, tostring(Item))
	end
	return table.concat(Strings, " ")
end;

return Tokens
]]

local Import = require"Toolbox.Import"

local Compiler = require"Sisyphus2.Compiler"

local Pattern = Import.Module.Relative"Pattern"

return Compiler.Object(
	"Nested.PEG.Syntax.Tokens", {
		Construct = function(self, Patterns)
			self.Patterns = Compiler.Objects.Array("Nested.PEG", Patterns)
		end;

		Decompose = function(self, Canonical)
			local v = Pattern.Syntax.Tokens(unpack(self.Patterns(Canonical)))
			assert(type(v) == "userdata")
			return v
		end;
		
		Copy = function(self)
			return (-self.Patterns).Items
		end;

		ToString = function(self)
			local Strings = {}
			for _, Item in pairs(self.Patterns.Items) do
				table.insert(Strings, tostring(Item))
			end
			return table.concat(Strings, " ")
		end;
	}
)
