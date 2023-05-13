local Lookup = {}

function Lookup.AliasableType(In, Path)
	if Path then
		if In%"Aliasable.Namespace" then
			local Found = Lookup.AliasableType(In.Children.Entries:Get(Path.Name), Path.Namespace)
			return Found
		else
			error"Should be an Aliasable.Namespace"
		end
	else
		return In
	end
end

return Lookup
