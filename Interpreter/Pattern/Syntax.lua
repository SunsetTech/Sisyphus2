local Import = require"Toolbox.Import"

local Vlpeg = require"Sisyphus2.Vlpeg"

local Static = Import.Module.Sister"Static"

local Package = {}

Package = {
	Concatenate = function(Seperator, First, ...)
		local Rest = {...}
		local Parts = {First}
		for Index = 1, #Rest do
			table.insert(Parts, Seperator)
			table.insert(Parts, Rest[Index])
		end
		local New = Vlpeg.Sequence(table.unpack(Parts))
		--[[local New = (Next
			and Package.Concatenate(
				Seperator, 
				Vlpeg.Sequence(First, Seperator, Next), ...
			)
			or First
		)]]
		return New
	end;

	Tokens = function(...)
		local New = Package.Concatenate(Static.Whitespace^0, ...)
		return New
	end;
}

return Package
