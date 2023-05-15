local Module = require"Moonrise.Import.Module"

local Structure = require"Sisyphus2.Structure"
local Basic = Structure.Basic
local PEG = Structure.Nested.PEG
local Variable = PEG.Variable

local Construct = require"Sisyphus2.Interpreter.Objects.Construct"
local Dynamic = require"Sisyphus2.Interpreter.Parse.Dynamic"

return Basic.Namespace{
	Name = Module.Child"Name";
	Template = Module.Child"Template";
	Grammar = Module.Child"Grammar";
	Root = Module.Child"Root";
	String = require"Sisyphus2.Grammar.Types.Basic.String";
	Modified = Basic.Type.Definition(
		Dynamic.Jump(
			Construct.Invocation( 
				"@",
				Construct.ArgumentList{Variable.Canonical"Types.Basic.Grammar.Modifier"},
				function(Grammar)
					return Grammar/"userdata", {
						Grammar = Grammar;
						Variables = {};
					}
				end
			)
		)
	);
}
