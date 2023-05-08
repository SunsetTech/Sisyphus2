local Import = require"Toolbox.Import"

local Structure = require"Sisyphus2.Structure"
local Aliasable = Structure.Aliasable
local Basic = Structure.Basic
local Nested = Structure.Nested
local PEG = Nested.PEG
local Variable = PEG.Variable

local Construct = require"Sisyphus2.Interpreter.Objects.Construct"
local Syntax = require"Sisyphus2.Interpreter.Objects.Syntax"
local Static = require"Sisyphus2.Interpreter.Objects.Static"

local function Compare(Switch, Left, Right)
	return 
		Switch
		and Left
		or Right
end

return Basic.Type.Set{
	If = Basic.Type.Definition(
		Syntax.Tokens{
			PEG.Pattern"If",
			Construct.ChangeGrammar(
				PEG.Apply(
					PEG.Sequence{
						PEG.Stored"Basetype",
						Static.GetEnvironment
					},
					function(Basetype, Environment)
						local GrammarCopy = Environment.Grammar:Copy()

						GrammarCopy.InitialPattern = Aliasable.Type.Definition(
							Construct.ArgumentList{
								Construct.AliasableType"Data.Boolean",
								Construct.AliasableType(Basetype),
								Construct.AliasableType(Basetype)
							}, 
							Compare
						)/"Nested.Grammar"
						
						return GrammarCopy
					end
				)
			)
		}
	);
}
