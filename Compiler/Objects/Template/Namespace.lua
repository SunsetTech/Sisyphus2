local Import = require"Moonrise.Import"

local Map = Import.Module.Relative"Objects.Map2"
local Aliasable = Import.Module.Relative"Objects.Aliasable"

local OOP = require"Moonrise.OOP"

local Namespace = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Template.Namespace", {
		require"Sisyphus2.Compiler.Object"
	}
)

Namespace.Initialize = function(_, self, Children, Base, _Children)
	self.Base = Base or Aliasable.Namespace()
	self.Children = _Children or Map({"Template.Namespace", "Template.Definition"}, Children or {})
end;

Namespace.Decompose = function(self)
	return
		self.Base
		+ Aliasable.Namespace(self.Children())
end;

Namespace.Copy = function(self)
	return Namespace(nil, self.Base, self.Children:Copy())
end;

Namespace.Merge = function(Into, From)
	Into.Base:Merge(From.Base)
	Into.Children:Merge(From.Children)
end

return Namespace
