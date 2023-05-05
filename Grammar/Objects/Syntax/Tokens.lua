
local Import = require"Toolbox.Import"
local Compiler = require"Sisyphus2.Compiler"
local Pattern = Import.Module.Relative"Pattern"

local OOP = require"Moonrise.OOP"

local Tokens = OOP.Declarator.Shortcuts(
	"Nested.PEG.Syntax.Tokens", {
		require"Sisyphus2.Compiler.Object"
	}
)

Tokens.Initialize = function(_, self, Patterns, _Patterns)
	self.Patterns = _Patterns or Compiler.Objects.Array("Nested.PEG", Patterns)
	self.Decompose = Tokens.Decompose
	self.Copy = Tokens.Copy
	self.ToString = Tokens.ToString
end;

Tokens.Decompose = function(self, Canonical)
	assert(#self.Patterns(Canonical)>0)
	local v = Pattern.Syntax.Tokens(unpack(self.Patterns(Canonical)))
	assert(type(v) == "userdata")
	return v
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

--[[local Import = require"Toolbox.Import"

local Compiler = require"Sisyphus2.Compiler"

local Pattern = Import.Module.Relative"Pattern"

return Compiler.Object(
	"Nested.PEG.Syntax.Tokens", {
		Construct = function(self, Patterns, _Patterns)
			self.Patterns = _Patterns or Compiler.Objects.Array("Nested.PEG", Patterns)
		end;

		Decompose = function(self, Canonical)
			local v = Pattern.Syntax.Tokens(unpack(self.Patterns(Canonical)))
			assert(type(v) == "userdata")
			return v
		end;
		
		Copy = function(self)
			return nil, (self.Patterns:Copy())
		end;

		ToString = function(self)
			local Strings = {}
			for _, Item in pairs(self.Patterns.Items) do
				table.insert(Strings, tostring(Item))
			end
			return table.concat(Strings, " ")
		end;
	}
)]]
