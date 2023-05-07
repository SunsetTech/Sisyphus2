local OOP = require"Moonrise.OOP"

local Array = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Array", {
		require"Sisyphus2.Structure.Object"
	}
)

Array.Initialize = function(_, self, Type, Items)
	self.Type = Type
	self.Items = Items
	self.Decompose = Array.Decompose
	self.Copy = Array.Copy
end;

Array.Decompose = function(self, ...)
	local Count = select("#", ...)
	local Args = {...}
	local Decomposed = {}
	
	for Index = 1, #self.Items do
		local Item = self.Items[Index]
		--Tools.Error.CallerAssert(type(Index) == "number", "Expected a numeric index, got ".. Index)
		--Tools.Error.CallerAssert(Item%(self.Type), "Expected a ".. self.Type)
	
		Decomposed[Index] = Item(table.unpack(Args,1,Count))
	end

	return Decomposed
end;

Array.Copy = function(self)
	local ItemsCopy = {}
	
	for Index = 1, #self.Items do
		local Item = self.Items[Index]
		ItemsCopy[Index] = Item:Copy()
	end
	
	return Array(self.Type, ItemsCopy)
end;

return Array
