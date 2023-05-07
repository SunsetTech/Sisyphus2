local Module = require"Toolbox.Import.Module"

local Structure = require"Sisyphus2.Structure"
local Basic = Structure.Basic
local Nested = Structure.Nested
local PEG = Nested.PEG

local Construct = require"Sisyphus2.Interpreter.Objects.Construct"

return Basic.Type.Definition(
		Construct.Centered(
			PEG.Select{
				Construct.BasicNamespace"Modified",
				Construct.AliasableType"Data.String"
			}
		),
		nil,
		Basic.Namespace{
			Templates = Module.Child"Templates";
		}
	);
