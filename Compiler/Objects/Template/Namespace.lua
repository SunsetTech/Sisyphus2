local Import = require"Moonrise.Import"

local Map = Import.Module.Relative"Objects.Map"
local Aliasable = Import.Module.Relative"Objects.Aliasable"

local OOP = require"Moonrise.OOP"

local Namespace = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Template.Namespace", {
		require"Sisyphus2.Compiler.Object"
	}
)

Namespace.Initialize = function(_, self, Children, Base)
	self.Base = Base or Aliasable.Namespace()
	self.Children = Map({"Template.Namespace", "Template.Definition"}, Children or {})
end;

Namespace.Decompose = function(self)
	return
		self.Base
		+ Aliasable.Namespace(self.Children())
end;

Namespace.Copy = function(self)
	return Namespace((-self.Children).Entries, self.Base)
end;

Namespace.Merge = function(Into, From)
	Into.Base = Into.Base + From.Base
	Into.Children = Into.Children + From.Children
end

return Namespace
