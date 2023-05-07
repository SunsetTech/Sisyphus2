local Template = require"Sisyphus2.Structure.Template"
local Namespace = {}

function Namespace.Template(Entry, Canonical)
	local Namespace = Template.Namespace()--[[{
		[Canonical.Name] = Entry;
	}]]
	Namespace.Children.Entries:Add(Canonical.Name, Entry)
	
	if Canonical.Namespace then
		return Namespace.Template(
			Namespace,
			Canonical.Namespace
		)
	else
		return Namespace
	end
end

return Namespace
