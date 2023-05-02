local OOP = require"Moonrise.OOP"

local Merger = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Merger", {
		require"Sisyphus2.Compiler.Object"
	}
)

Merger.Initiailize = function(_,self, Type, Items)
	self.Type = Type
	self.Items = Items
end;

Merger.Decompose = function(self)
	local Merged
	if (#self.Items >= 2) then
		local First = self.Items[1]
		local Rest = {}
		for Index = 2, #self.Items do
			local Item = self.Items[Index]
			
			--Tools.Error.CallerAssert(Item%(self.Type), Format"Expected a %s, got a %s"(self.Type, type(Item)), 1)
			
			table.insert(Rest, Item)
		end

		return First + Rest
	elseif (#self.Items == 1) then
		return self.Items[1]
	end
end;

return Merger
