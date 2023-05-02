local Module = require"Moonrise.Import.Module"

local Compiler = require"Sisyphus2.Compiler"

return Compiler.Objects.Aliasable.Namespace{
	Data = Module.Child"Data";
}
