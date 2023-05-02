local Import = require"Toolbox.Import"
local Tools = require"Toolbox.Tools"

local Iterate = {Canonical = Import.Module.Sister"Iterate.Canonical"}

--Locate a node inside a namespace by its canonical name
--[[function Package.Node(Namespace, Canonical)
	local Result = Namespace.Children.Entries[Canonical.Name]
	
	return 
		Canonical.Namespace
		and Package.Lookup(Result, Canonical.Namespace)
		or Result
end]]

local Lookup = {}

function Lookup.AliasableType(At, Canonical)
	--assert(not(Canonical.Name == "Data" and Canonical.Namespace.Name == "String"))
	for Name in Iterate.Canonical.End(Canonical) do
		--print("Lookup", Name)
		Tools.Error.CallerAssert(At and At%"Aliasable.Namespace", Tools.String.Format"Can't lookup %s in %s"(Canonical(), At))
		At = At.Children.Entries[Name]
	end
	
	--Tools.Error.CallerAssert(In and In%"Aliasable.Type.Definition", "Didnt find an aliasable type, got ".. #Entry)

	return At
end

return Lookup
