
local Nested = require"Sisyphus2.Compiler.Objects.Nested"

local Basic = {
	Namespace = require"Sisyphus2.Compiler.Objects.Basic.Namespace";
}

local OOP = require"Moonrise.OOP"

local Grammar = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Basic.Grammar", {
		require"Sisyphus2.Compiler.Object"
	}
)

Grammar.Initialize = function(_, self, InitialPattern, Types, Syntax)
	self.InitialPattern = InitialPattern
	self.Types = Types or Basic.Namespace()
	self.Syntax = Syntax or Nested.Grammar()
	self.Decompose = Grammar.Decompose
end;

Grammar.Decompose = function(self)
	local Nested = Nested.Grammar()
	Nested.Rules.Entries:Add(1, self.InitialPattern)
	Nested.Rules.Entries:Add("Types", self.Types())
	Nested.Rules.Entries:Add("Syntax", self.Syntax)
	return Nested
	--[[{
		self.InitialPattern,
		Types = self.Types();
		Syntax = self.Syntax;
	}]]
end;

return Grammar
