local Import = require"Moonrise.Import"

local Map = Import.Module.Relative"Objects.Map"
local Basic = Import.Module.Relative"Objects.Basic"

local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Compiler.Objects.Aliasable.Namespace : Sisyphus2.Compiler.Object
---@operator call:Sisyphus2.Compiler.Objects.Aliasable.Namespace
---@field Children Sisyphus2.Compiler.Objects.Map
local Namespace = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Aliasable.Namespace", {
		require"Sisyphus2.Compiler.Object"
	}
)


Namespace.Initialize = function(_, self, Children, Base, _Children)
	self.Base = Base or Basic.Namespace()
	if _Children then 
		self.Children = _Children
	else
		self.Children = Map({"Aliasable.Namespace", "Aliasable.Type.Definition"}, Children)
	end
end;

Namespace.Decompose = function(self) -- into a Basic.Namespace
	return 
		self.Base
		+ Basic.Namespace(self.Children())
end;

Namespace.Copy = function(self)
	return Namespace(nil, -self.Base, -self.Children)
end;

Namespace.Merge = function(Into, From)
	Into.Base = Into.Base + From.Base
	Into.Children = Into.Children + From.Children
end;

return Namespace
