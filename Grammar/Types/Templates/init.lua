local Module = require"Toolbox.Import.Module"

local Structure = require"Sisyphus2.Structure"
local Template = Structure.Template

return Template.Namespace{
	Functions = Module.Child"Functions";
}
