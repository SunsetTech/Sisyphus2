local Template = require"Sisyphus2.Structure.Template"
local Namespace = {}

function Namespace.Template(Entry, Canonical)
	local Namespace = Template.Namespace()--[[{
		[Canonical.Name] = Entry;
	}]]
	Namespace.Children.Entries:Add(Canonical.Name, Entry)
	
	if Canonical.Namespace then
		local New = Namespace.Template(
			Namespace,
			Canonical.Namespace
		)
		return New
	else
		return Namespace
	end
end

return Namespace
