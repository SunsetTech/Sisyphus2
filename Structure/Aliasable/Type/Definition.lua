local Tools = require"Moonrise.Tools"
local Import = require"Moonrise.Import"
local Execution = require "Sisyphus2.Interpreter.Execution"
local AliasList = Import.Module.Sister"AliasList"
local Basic = Import.Module.Relative"Basic"
local Nested = Import.Module.Relative"Nested"
local Completable = Import.Module.Relative"PEG.Completable"
local Namespace = Import.Module.Relative"Namespace"

local OOP = require"Moonrise.OOP"

local Definition = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Aliasable.Type.Definition", {
		require"Sisyphus2.Structure.Object"
	}
)

Definition.Initialize = function(_, self, Pattern, Function, Syntax, AliasableTypes, BasicTypes, Aliases)
	--require"Moonrise.Tools.Debug".PrintStack()
	--assert(OOP.Reflection.Type.Of(Execution.NamedFunction,Function))
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
	Grammar.Rules.Entries:Add("Aliases", self.Aliases:Decompose())
	Grammar:Merge(self.Syntax)
	local Namespace = Basic.Namespace()
	Namespace.Children.Entries:Add("Aliasable", self.AliasableTypes:Decompose())
	Namespace.Children.Entries:Add("Basic", self.BasicTypes)
	local New = Basic.Type.Definition(
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
	return New
end;

Definition.Copy = function(self)
	local New = Definition(self.Pattern:Copy(), self.Function, self.Syntax:Copy(), self.AliasableTypes:Copy(), self.BasicTypes:Copy(), (self.Aliases:Copy()).Names)
	return New
end;

Definition.Merge = function(Into, From)
end;

return Definition
