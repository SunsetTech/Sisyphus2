local PEG = require"Sisyphus2.Compiler".Objects.Nested.PEG
local Vlpeg = require"Sisyphus2.Vlpeg"

return {
	Alpha = PEG.Range("az","AZ");
	GetEnvironment = PEG.Pattern(Vlpeg.Args(1));
	Whitespace = PEG.Select{PEG.Pattern"\r\n", PEG.Pattern"\n", PEG.Set" \t"};
}
