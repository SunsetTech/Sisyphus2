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

local function Branch(Switch, Left, Right)
	print(Switch, Left, Right)
	if Execution.ResolveArgument(Switch) then
		return Execution.ResolveArgument(Left)
	else
		return Execution.ResolveArgument(Right)
	end
	--[[return 
		Execution.Switch
		and Left
		or Right]]
end
print("Branch = ".. tostring(Branch))
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
						print(Basetype, ExpressionType:Decompose(true), Field, Environment)
						local GrammarCopy = Environment.Grammar:Copy()

						GrammarCopy.InitialPattern = Aliasable.Type.Definition(
							Construct.Centered(
								Construct.ArgumentList{
									Construct.AliasableType(ExpressionType:Decompose(true))
								}
							),
							Execution.NamedFunction(
								"Get",function(From)
									print("Getting from", From)
									local Result = From.Fields[Field]
									print("Got", Result)
									print("TODO: type check the result")
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
