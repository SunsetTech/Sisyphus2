local Import = require"Toolbox.Import"

local Vlpeg = require"Sisyphus2.Vlpeg"

return {
	Whitespace = Vlpeg.Pattern"\r\n" + Vlpeg.Pattern"\n" + Vlpeg.Set" \t";
};
