local OOP = require"Moonrise.OOP"

local Array = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Array", {
		require"Sisyphus2.Structure.Object"
	}
)

local Decompose = function(self, Argument)
	local Decomposed = {}
	
	for Index = 1, #self.Items do
		local Item = self.Items[Index]

		Decomposed[Index] = Item:Decompose(Argument)
	end

	return Decomposed
end;

local Copy = function(self)
	local ItemsCopy = {}
	
	for Index = 1, #self.Items do
		ItemsCopy[Index] = self.Items[Index]:Copy()
	end
	
	local New = Array(self.Type, ItemsCopy)
	return New
end;


Array.Initialize = function(_, self, Type, Items)
	self.Type = Type
	self.Items = Items
	self.Decompose = Decompose
	self.Copy = Copy
end;
return Array
