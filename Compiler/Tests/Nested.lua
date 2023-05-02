local Import = require"Moonrise.Import"

local Vlpeg = Import.Module.Relative"Vlpeg"
local Nested = Import.Module.Relative"Objects.Nested"
local PEG = Nested.PEG
local Variable = PEG.Variable

return function()
	local TestNestedGrammar = Nested.Grammar{
		A = PEG.Pattern"A";
		B = Nested.Grammar{
			C = PEG.Pattern"C";
			D = PEG.Pattern"D";
			PEG.Select{Variable.Child"C", Variable.Child"D"};
		};
		PEG.Select{Variable.Child"A", Variable.Child"B";}
	}
	
	local TestFlatGrammar = TestNestedGrammar()
	local TestGrammar = TestFlatGrammar()
	
	assert(Vlpeg.Match(TestGrammar, "A"))
	assert(Vlpeg.Match(TestGrammar, "C"))
	assert(Vlpeg.Match(TestGrammar, "D"))
end
