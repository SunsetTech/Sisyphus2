local Module = require"Moonrise.Import.Module"

local Compiler = require"Sisyphus2.Compiler"
local Basic = Compiler.Objects.Basic
local PEG = Compiler.Objects.Nested.PEG
local Variable = PEG.Variable

local Syntax = Module.Relative"Objects.Syntax"
local Construct = Module.Relative"Objects.Construct"

return Basic.Namespace{
	Name = Module.Child"Name";
	Template = Module.Child"Template";
	Grammar = Module.Child"Grammar";
	Root = Module.Child"Root";

	Modified = Basic.Type.Definition(
		Construct.DynamicParse(
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
