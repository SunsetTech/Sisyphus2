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
end;

Definition.Decompose = function(self)
	return Basic.Type.Definition(
		Nested.PEG.Select{ 
			Completable(
				self.Pattern,
				self.Function
			),
			Nested.PEG.Variable.Child"Syntax.Aliases"
		}, (
			Nested.Grammar{
				Aliases = self.Aliases();
			}
			+ self.Syntax
		),
		Basic.Namespace{
			Aliasable = self.AliasableTypes();
			Basic = self.BasicTypes;
		}
	)
end;

Definition.Copy = function(self)
	return Definition(-self.Pattern, self.Function, -self.Syntax, -self.AliasableTypes, -self.BasicTypes, (-self.Aliases).Names)
end;

Definition.Merge = function(Into, From)
	print("Not merging ".. tostring(Into) .." with ".. tostring(From))
	print("TODO: fix this by dropping one of the duplicate types")
end;

return Definition
