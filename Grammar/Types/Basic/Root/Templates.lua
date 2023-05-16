local OOP = require"Moonrise.OOP"

local Structure = require"Sisyphus2.Structure"
local Aliasable = Structure.Aliasable
local Basic = Structure.Basic
local Nested = Structure.Nested
local PEG = Nested.PEG

local Construct = require"Sisyphus2.Interpreter.Objects.Construct"
local Syntax = require"Sisyphus2.Interpreter.Objects.Syntax"
local Static = require"Sisyphus2.Interpreter.Parse.Static"
local Execution = require"Sisyphus2.Interpreter.Execution"
local Dynamic = require"Sisyphus2.Interpreter.Parse.Dynamic"
local Box = require"Sisyphus2.Interpreter.Execution.Box"

local function Branch(Switch, Left, Right)
	if Switch then
		return Left
	else
		return Right
	end
end

return Basic.Type.Set{
	Get = Basic.Type.Definition(
		Syntax.Tokens{
			PEG.Pattern"Get",
			Dynamic.Grammar(
				PEG.Apply(
					PEG.Sequence{
						PEG.Stored"Basetype",
						Construct.ArgumentList{
							PEG.Variable.Canonical"Types.Basic.Name.Target",
							PEG.Variable.Canonical"Types.Basic.Name.Part"
						},
						Static.GetEnvironment
					},
					function(Basetype, ExpressionType, Field, Environment)
						local GrammarCopy = Environment.Grammar

						GrammarCopy.InitialPattern = Aliasable.Type.Definition(
							Construct.Centered(
								Construct.ArgumentList{
									Construct.AliasableType(ExpressionType:Decompose(true))
								}
							),
							Execution.NamedFunction(
								"<-",function(From)
									local Result = From.Fields[Field]
									
									if (OOP.Reflection.Type.Of(Box, Result)) then
										assert(Basetype == Result.Type)
									else
										print("TODO", Result, "wasn't a box but should be")
									end
									
									return Result
								end
							)
						)/"Nested.Grammar"
						
						return GrammarCopy
					end
				)
			)
		}
	);
	If = Basic.Type.Definition(
		Syntax.Tokens{
			PEG.Pattern"If",
			Dynamic.Grammar(
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
							Execution.NamedFunction("Branch",Branch)
						)/"Nested.Grammar"
						
						return GrammarCopy
					end
				)
			)
		}
	);
}
