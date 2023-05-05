local Module = require"Moonrise.Import.Module"

return {
	Grammar = Module.Child"Grammar";
	Rule = Module.Child"Rule";
	PEG = require"Sisyphus2.Compiler.Objects.Nested.PEG";
}
