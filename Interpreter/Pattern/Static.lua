local Import = require"Toolbox.Import"

local Vlpeg = require"Sisyphus2.Vlpeg"

return {
	Whitespace = Vlpeg.Pattern"\r\n" + Vlpeg.Pattern"\n" + Vlpeg.Set" \t" + (Vlpeg.Pattern"[[" * (Vlpeg.Pattern(1)-Vlpeg.Pattern"]]")^0 * Vlpeg.Pattern"]]");
};
