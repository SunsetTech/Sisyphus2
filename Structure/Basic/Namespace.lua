local OrderedMap = require"Moonrise.Object.OrderedMap"

local Map = require"Sisyphus2.Structure.Map"
local Nested = require"Sisyphus2.Structure.Nested"

local Namespace = require"Moonrise.OOP".Declarator.Shortcuts(
	"Sisyphus2.Structure.Basic.Namespace", {
		require"Sisyphus2.Structure.Object"
	}
)


Namespace.Initialize = function(_, self, Children, _Children)
	if _Children then 
		self.Children = _Children
	else
		self.Children = Map({"Basic.Namespace", "Basic.Type.Definition", "Basic.Type.Set"},Children)
	end
	self.Decompose = Namespace.Decompose
	self.Copy = Namespace.Copy
	self.Merge = Namespace.Merge
end;

local GetPair = OrderedMap.GetPair

Namespace.Decompose = function(self) --into a Nested.Grammar
	local NewGrammar = Nested.Grammar()
	for Index = 1, self.Children.Entries:NumKeys() do
		local Name, Entry = GetPair(self.Children.Entries, Index)
		NewGrammar.Rules.Entries:Add(Name, Entry:Decompose())
	end
	return NewGrammar 
		--Nested.Grammar(self.Children())
end;

Namespace.Copy = function(self)
	local New = Namespace(nil, self.Children:Copy())
	return New
end;

Namespace.Merge = function(Into, From)
	Into.Children:Merge(From.Children)
	--Into.Children = Map({"Basic.Namespace","Basic.Type.Definition","Basic.Type.Set"},{}) + {Into.Children, From.Children}
end;

return Namespace
