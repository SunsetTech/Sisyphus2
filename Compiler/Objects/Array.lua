local OOP = require"Moonrise.OOP"

local Array = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Array", {
		require"Sisyphus2.Compiler.Object"
	}
)

Array.Initialize = function(_, self, Type, Items)
	assert(Items)
	self.Type = Type
	self.Items = Items
	--for Index, Item in pairs(self.Items) do
	for Index = 1, #self.Items do
		local Item = self.Items[Index]
		--Tools.Error.CallerAssert(type(Index) == "number", "Expected a numeric index, got ".. Index)
		--Tools.Error.CallerAssert(Item%(self.Type), "Expected a ".. self.Type)
	end
end;

Array.Decompose = function(self, ...)
	local Decomposed = {}
	
	for Index = 1, #self.Items do
		local Item = self.Items[Index]
		--Tools.Error.CallerAssert(type(Index) == "number", "Expected a numeric index, got ".. Index)
		--Tools.Error.CallerAssert(Item%(self.Type), "Expected a ".. self.Type)
	
		Decomposed[Index] = Item(...)
	end

	return Decomposed
end;

Array.Copy = function(self)
	local ItemsCopy = {}
	
	for Index = 1, #self.Items do
		local Item = self.Items[Index]
		ItemsCopy[Index] = -Item
	end
	
	return Array(self.Type, ItemsCopy)
end;

return Array
