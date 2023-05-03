local Module = require"Toolbox.Import.Module"

return {
	Argument = Module.Child"Argument";
	Definition = Module.Child"Definition";
	Type = Module.Child"Type";
	Namespace = require"Sisyphus2.Grammar.Generate.Namespace";
}
