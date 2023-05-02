local PEG = require"Sisyphus.Compiler".Objects.Nested.PEG
local Vlpeg = require"Sisyphus.Vlpeg"

return {
	Alpha = PEG.Range("az","AZ");
	GetEnvironment = PEG.Pattern(Vlpeg.Args(1));
	Whitespace = PEG.Select{PEG.Pattern"\r\n", PEG.Pattern"\n", PEG.Set" \t"};
}
