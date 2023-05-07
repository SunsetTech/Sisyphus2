local Import = require"Moonrise.Import"
local Tools = require"Moonrise.Tools"

local Nested = Import.Module.Relative"Nested"
local Basic = Import.Module.Relative"Basic"

local Aliasable = {
	Namespace = Import.Module.Sister"Namespace";
}

local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Aliasable.Grammar : Sisyphus2.Structure.Object
---@field InitialPattern Sisyphus2.Structure.Nested.PEG.Base
local Grammar = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Aliasable.Grammar", {
		require"Sisyphus2.Structure.Object"
	}
)

Grammar.Initialize = function(_, self, InitialPattern, AliasableTypes, BasicTypes, Syntax, Information)
	self.InitialPattern = InitialPattern
	self.BasicTypes = BasicTypes or Basic.Namespace()
	self.AliasableTypes = AliasableTypes or Aliasable.Namespace()
	self.Syntax = Syntax or Nested.Grammar()
	self.Information = Information or {}
	self.Decompose = Grammar.Decompose
	self.Copy = Grammar.Copy
end;

Grammar.Decompose = function(self)
	local Namespace = Basic.Namespace()
	Namespace.Children.Entries:Add("Aliasable", self.AliasableTypes())
	Namespace.Children.Entries:Add("Basic", self.BasicTypes)
	return Basic.Grammar(
		self.InitialPattern,
		Namespace,
		self.Syntax
	)
end;

Grammar.Copy = function(self)
	return Grammar(
		self.InitialPattern:Copy(), 
		self.AliasableTypes:Copy(), 
		self.BasicTypes:Copy(), 
		self.Syntax:Copy(), 
		Tools.Table.Copy(self.Information)
	)
end;

return Grammar
