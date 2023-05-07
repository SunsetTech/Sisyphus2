local Import = require "Moonrise.Import"
local Pretty = require"Moonrise.Tools.Pretty"
local Vlpeg = Import.Module.Relative"Vlpeg"
local Aliasable = Import.Module.Relative"Aliasable"
local Nested = Import.Module.Relative"Nested"

return function()
	local ADefinition = Aliasable.Type.Definition(
		Nested.PEG.Capture(Nested.PEG.Variable.Child"Syntax.Token"),
		function(Token)
			return Token .."+"
		end,
		Nested.Grammar{
			Token = Nested.PEG.Pattern"A"
		}
	)
	
	
	local TestAliasableGrammar = Aliasable.Grammar(
		Nested.PEG.Variable.Child"Types.Aliasable.A",
		Aliasable.Namespace{
			A = ADefinition; 
		}
	)
	local TestBasicGrammar = TestAliasableGrammar()
	local TestNestedGrammar = TestBasicGrammar()
	local TestFlatGrammar = TestNestedGrammar()
	local TestGrammar = TestFlatGrammar()
	local TestOutput = Vlpeg.Match(TestGrammar,"A")
	assert(TestOutput == "A+")
end
