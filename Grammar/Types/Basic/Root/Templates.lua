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
local Execution = require"Sisyphus2.Interpreter.Execution"

local function Branch(Switch, Left, Right)
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
							Execution.NamedFunction("Branch",Branch)
						)/"Nested.Grammar"
						
						return GrammarCopy
					end
				)
			)
		}
	);
}
