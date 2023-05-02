local Import = require"Toolbox.Import"

local Vlpeg = require"Sisyphus2.Vlpeg"

local Static = Import.Module.Sister"Static"

local Package = {}

Package = {
	Concatenate = function(Seperator, First, Next, ...)
		return (Next
			and Package.Concatenate(
				Seperator, 
				Vlpeg.Sequence(First, Seperator, Next), ...
			)
			or First
		)
	end;

	Tokens = function(...)
		return Package.Concatenate(Static.Whitespace^0, ...)
	end;

	Array = function(Pattern, Seperator, Joiner)
		Joiner = Joiner or Package.Tokens
		return Joiner(Pattern,Joiner(Seperator, Pattern)^0)
	end;
}

return Package
