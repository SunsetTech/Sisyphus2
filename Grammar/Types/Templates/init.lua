local Module = require"Toolbox.Import.Module"

local Compiler = require"Sisyphus2.Compiler"
local Template = Compiler.Objects.Template

return Template.Namespace{
	Functions = Module.Child"Functions";
}
