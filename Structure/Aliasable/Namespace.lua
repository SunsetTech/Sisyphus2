local Import = require"Moonrise.Import"

local Map = Import.Module.Relative"Map"
local Basic = Import.Module.Relative"Basic"

local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Aliasable.Namespace : Sisyphus2.Structure.Object
---@operator call:Sisyphus2.Structure.Aliasable.Namespace
---@field Children Sisyphus2.Structure.Map
local Namespace = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Aliasable.Namespace", {
		require"Sisyphus2.Structure.Object"
	}
)


local Decompose = function(self) -- into a Basic.Namespace
	local Basics = Basic.Namespace()
	for Index = 1, self.Children.Entries:NumKeys() do
		local Name, Entry = self.Children.Entries:GetPair(Index)
		Basics.Children.Entries:Add(Name, Entry:Decompose())
	end
	local Base = self.Base:Copy()
	Base:Merge(Basics)
	return Base
	--[[return 
		self.Base
		+ Basic.Namespace(self.Children())]]
end;

local Copy = function(self)
	local New = Namespace(nil, self.Base:Copy(), self.Children:Copy())
	return New
end;

local Merge = function(Into, From)
	Into.Base:Merge(From.Base)
	Into.Children:Merge(From.Children)
	--Into.Base = Into.Base + From.Base
	--Into.Children = Into.Children + From.Children
end;

Namespace.Initialize = function(_, self, Children, Base, _Children)
	self.Base = Base or Basic.Namespace()
	if _Children then 
		self.Children = _Children
	else
		self.Children = Map({"Aliasable.Namespace", "Aliasable.Type.Definition"}, Children)
	end
	self.Decompose = Decompose
	self.Copy = Copy
	self.Merge = Merge
end;

return Namespace
