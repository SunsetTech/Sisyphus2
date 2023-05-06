local Map = require"Sisyphus2.Compiler.Objects.Map2"
local Nested = require"Sisyphus2.Compiler.Objects.Nested"

local OOP = require"Moonrise.OOP"

local Namespace = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Basic.Namespace", {
		require"Sisyphus2.Compiler.Object"
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

Namespace.Decompose = function(self) --into a Nested.Grammar
	local NewGrammar = Nested.Grammar()
	for Index = 1, self.Children.Entries:NumKeys() do
		local Name, Entry = self.Children.Entries:GetPair(Index)
		NewGrammar.Rules.Entries:Add(Name, Entry())
	end
	return NewGrammar 
		--Nested.Grammar(self.Children())
end;

Namespace.Copy = function(self)
	return Namespace(nil, self.Children:Copy())
end;

Namespace.Merge = function(Into, From)
	Into.Children:Merge(From.Children)
	--Into.Children = Map({"Basic.Namespace","Basic.Type.Definition","Basic.Type.Set"},{}) + {Into.Children, From.Children}
end;

return Namespace
