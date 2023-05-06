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
	self.Children = _Children or Map({"Template.Namespace", "Template.Definition"}, Children)
end;

Namespace.Decompose = function(self)
	local Aliasables = Aliasable.Namespace()
	for Index = 1, self.Children.Entries:NumKeys() do
		local Name, Entry = self.Children.Entries:GetPair(Index)
		Aliasables.Children.Entries:Add(Name, Entry())
	end
	local Base = self.Base:Copy()
	Base:Merge(Aliasables)
	return Base
end;

Namespace.Copy = function(self)
	return Namespace(nil, self.Base, self.Children:Copy())
end;

Namespace.Merge = function(Into, From)
	Into.Base:Merge(From.Base)
	Into.Children:Merge(From.Children)
end

return Namespace
