local Import = require"Moonrise.Import"

local Vlpeg = Import.Module.Relative"Vlpeg"
local Basic = Import.Module.Relative"Objects.Basic"
local Nested = Import.Module.Relative"Objects.Nested"

local PEG = Nested.PEG
local Variable = PEG.Variable

return function()
	local TestBasicGrammar = Basic.Grammar(
		PEG.Select{
			Variable.Child"Types.A", 
			Variable.Child"Types.B.C", 
			Variable.Child"Types.B.D"
		},
		Basic.Namespace{
			A = Basic.Type.Definition(
				PEG.Capture(Variable.Child"Syntax.Token"), 
				Nested.Grammar{
					Token = PEG.Pattern"A";
				}
			);
			B = Basic.Namespace{
				C = Basic.Type.Definition(
					PEG.Capture(Variable.Child"Syntax.Token"),
					Nested.Grammar{
						Token = PEG.Pattern"C";
					}
				);
				D = Basic.Type.Definition(
					PEG.Capture(Variable.Child"Syntax.Token"),
					Nested.Grammar{
						Token = PEG.Pattern"D";
					}
				);
			}
		}
	)

	local TestNestedGrammar = TestBasicGrammar()
	local TestFlatGrammar = TestNestedGrammar()
	local TestGrammar = TestFlatGrammar()
	
	assert(Vlpeg.Match(TestGrammar, "A") == "A")
	assert(Vlpeg.Match(TestGrammar, "C") == "C")
	assert(Vlpeg.Match(TestGrammar, "D") == "D")
end
