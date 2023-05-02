local Import = require"Toolbox.Import"

local CanonicalName = Import.Module.Relative"Objects.CanonicalName"

local Canonical = {}

function Canonical.Iterator(Current)
	return function()
		while Current do
			coroutine.yield(Current.Name)
			Current = Current.Namespace
		end
	end
end

function Canonical.Start(At)
	return coroutine.wrap(
		Canonical.Iterator(At)
	)
end

function Canonical.End(At)
	local Inverted
	
	for Name in Canonical.Start(At) do
		Inverted = CanonicalName(Name, Inverted)
	end
	
	return coroutine.wrap(
		Canonical.Iterator(Inverted)
	)
end

return Canonical
