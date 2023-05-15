local Structure = require"Sisyphus2.Structure"
local PEG = Structure.Nested.PEG
local Variable = PEG.Variable

return Structure.Basic.Type.Definition(
	Variable.Child"Syntax",
	Structure.Nested.Grammar{
		Delimiter = PEG.Pattern'"';
		Open = Variable.Sibling"Delimiter";
		Close = Variable.Sibling"Delimiter";
		Contents = PEG.Capture(
			PEG.All(
				require"Sisyphus2.Structure.Nested.PEG.Dematch"(
					PEG.Pattern(1),
					Variable.Sibling"Delimiter"
				)
			)
		);
		PEG.Sequence{Variable.Child"Open", Variable.Child"Contents", Variable.Child"Close"};
	}
);
