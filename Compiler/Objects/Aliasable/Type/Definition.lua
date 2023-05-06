local Tools = require"Moonrise.Tools"
local Import = require"Moonrise.Import"
local AliasList = Import.Module.Sister"AliasList"
local Basic = Import.Module.Relative"Objects.Basic"
local Nested = Import.Module.Relative"Objects.Nested"
local Completable = Import.Module.Relative"PEG.Completable"
local Namespace = Import.Module.Relative"Namespace"

local OOP = require"Moonrise.OOP"

local Definition = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Aliasable.Type.Definition", {
		require"Sisyphus2.Compiler.Object"
	}
)

Definition.Initialize = function(_, self, Pattern, Function, Syntax, AliasableTypes, BasicTypes, Aliases)
	self.Pattern = Pattern
	self.Function = Function
	self.Syntax = Syntax or Nested.Grammar()
	self.AliasableTypes = AliasableTypes or Namespace()
	self.BasicTypes = BasicTypes or Basic.Namespace()
	self.Aliases = AliasList(Aliases)
	self.Decompose = Definition.Decompose
	self.Copy = Definition.Copy
end;

Definition.Decompose = function(self)
	local Grammar = Nested.Grammar()
	Grammar.Rules.Entries:Add("Aliases", self.Aliases())
	Grammar:Merge(self.Syntax)
	local Namespace = Basic.Namespace()
	Namespace.Children.Entries:Add("Aliasable", self.AliasableTypes())
	Namespace.Children.Entries:Add("Basic", self.BasicTypes)
	return Basic.Type.Definition(
		Nested.PEG.Select{ 
			Completable(
				self.Pattern,
				self.Function
			),
			Nested.PEG.Variable.Child"Syntax.Aliases"
		}, 
		Grammar,
		Namespace
	)
end;

Definition.Copy = function(self)
	return Definition(-self.Pattern, self.Function, -self.Syntax, -self.AliasableTypes, -self.BasicTypes, (-self.Aliases).Names)
end;

Definition.Merge = function(Into, From)
end;

return Definition
