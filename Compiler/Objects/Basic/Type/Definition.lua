local type = require"Moonrise.Tools.Inspect".GetType

local Import = require"Moonrise.Import"
local Nested = Import.Module.Relative"Objects.Nested"

local Basic = {
	Grammar = Import.Module.Relative"Grammar";
	Namespace = Import.Module.Relative"Namespace";
}

local OOP = require"Moonrise.OOP"

local Definition = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Basic.Type.Definition", {
		require"Sisyphus2.Compiler.Object"
	}
)

Definition.Initialize = function(_, self, Pattern, Syntax, Types)
	self.Pattern = Pattern
	self.Syntax = Syntax or Nested.Grammar()
	self.Types = Types or Basic.Namespace();
end;

Definition.Decompose = function(self)
	return Basic.Grammar(
		self.Pattern,
		self.Types,
		self.Syntax
	)()
end;

Definition.Copy = function(self)
	return Definition(-self.Pattern, -self.Syntax, -self.Types)
end;

return Definition