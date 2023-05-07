local Import = require"Moonrise.Import"

local Vlpeg = Import.Module.Relative"Vlpeg"
local CanonicalName = Import.Module.Relative"CanonicalName"
local Template = Import.Module.Relative"Template"
local Aliasable = Import.Module.Relative"Aliasable"
local Nested = Import.Module.Relative"Nested"

return function()
	local TestTemplateGrammar = Template.Grammar(
		Aliasable.Grammar(
			Nested.PEG.Variable.Child"Types.Aliasable.A",
			Aliasable.Namespace{
				A = Aliasable.Type.Definition(
					Nested.PEG.Capture( Nested.PEG.Pattern"A"),
					function(Token)
						return Token .."+"
					end
				);
			}
		),
		Template.Namespace{
			B = Template.Definition(
				CanonicalName"A",
				Aliasable.Type.Definition(
					Nested.PEG.Capture(Nested.PEG.Pattern"B"),
					function(Token)
						return Token .."++"
					end
				)
			);
		}
	)
	local TestAliasableGrammar = TestTemplateGrammar()
	local TestBasicGrammar = TestAliasableGrammar()
	local TestNestedGrammar = TestBasicGrammar()
	local TestFlatGrammar = TestNestedGrammar()
	local TestGrammar = TestFlatGrammar()
	local A = Vlpeg.Match(TestGrammar,"A")
	assert(A == "A+")
	local B = Vlpeg.Match(TestGrammar,":B")
	assert(B == "B++")
end
