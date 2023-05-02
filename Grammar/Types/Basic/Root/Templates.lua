local Import = require"Toolbox.Import"

local Compiler = require"Sisyphus2.Compiler"
local Aliasable = Compiler.Objects.Aliasable
local Basic = Compiler.Objects.Basic
local Nested = Compiler.Objects.Nested
local PEG = Nested.PEG
local Variable = PEG.Variable

local Construct = Import.Module.Relative"Objects.Construct"
local Syntax = Import.Module.Relative"Objects.Syntax"
local Static = Import.Module.Relative"Objects.Static"

return Basic.Type.Set{
	If = Basic.Type.Definition(
		PEG.Debug(Syntax.Tokens{
			PEG.Pattern"If",
			Construct.ChangeGrammar(
				PEG.Apply(
					PEG.Sequence{
						PEG.Stored"Basetype",
						Static.GetEnvironment
					},
					function(Basetype, Environment)
						local GrammarCopy = -Environment.Grammar

						GrammarCopy.InitialPattern = Aliasable.Type.Definition(
							Construct.ArgumentList{
								Construct.AliasableType"Data.Boolean",
								Construct.AliasableType(Basetype),
								Construct.AliasableType(Basetype)
							},
							
							function(Switch, Left, Right)
								return 
									Switch
									and Left
									or Right
							end
						)/"Nested.Grammar"
						
						return GrammarCopy
					end
				)
			)
		}
	));
}
