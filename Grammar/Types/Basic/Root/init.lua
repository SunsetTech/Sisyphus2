local Module = require"Toolbox.Import.Module"

local Compiler = require"Sisyphus2.Compiler"
local Basic = Compiler.Objects.Basic
local Nested = Compiler.Objects.Nested
local PEG = Nested.PEG
local Variable = PEG.Variable

local Construct = Module.Relative"Objects.Construct"
local Static = Module.Relative"Objects.Static"

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
