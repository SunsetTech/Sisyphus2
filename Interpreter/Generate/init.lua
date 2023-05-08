local Module = require"Toolbox.Import.Module"

return {
	Argument = Module.Child"Argument";
	--Type = Module.Child"Type";
	Namespace = require"Sisyphus2.Interpreter.Generate.Namespace";
}
