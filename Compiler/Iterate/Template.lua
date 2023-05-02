local Import = require"Toolbox.Import"
local Tools = require"Toolbox.Tools"

local CanonicalName = Import.Module.Relative"Objects.CanonicalName"
local Lookup = Import.Module.Relative"Lookup"

local Template = {}

function Template.Register(Templates, AliasableTypes, Canonical)
	--print("??",Templates%"Template.Namespace")
	--print"Registration"
	for Name, Entry in pairs(Templates.Children.Entries) do
		--print("hh",Name,Entry)
		if Entry%"Template.Namespace" then
			Tools.Error.NotMine(
				Template.Register, 
				Entry, AliasableTypes, CanonicalName(Name, Canonical)
			)
		elseif Entry%"Template.Definition" then
			--assert(Entry.Basetype)
			--print("Finding", Entry.Basetype())
			local Target = Tools.Error.NotMine(
				Lookup.AliasableType,
				AliasableTypes, Entry.Basetype
			)
			--print("registering",CanonicalName(Name, Canonical)(),"with",Entry.Basetype())
			table.insert(Target.Aliases.Names, CanonicalName(Name, Canonical)())
		end
	end
end

return Template
