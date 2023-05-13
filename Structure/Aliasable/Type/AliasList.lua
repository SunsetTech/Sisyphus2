local Tools = require"Moonrise.Tools"

local PEG = require"Sisyphus2.Structure.Nested.PEG"

local OOP = require"Moonrise.OOP"

local Box = require"Sisyphus2.Interpreter.Execution.Box"
local Incomplete = require "Sisyphus2.Interpreter.Execution.Incomplete"
local Variable = require"Sisyphus2.Interpreter.Execution.Variable"
local Unboxer = require"Sisyphus2.Interpreter.Execution.Unboxer"

local AliasList = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Aliasable.Type.AliasList", {
		require"Sisyphus2.Structure.Object"
	}
)

local Decompose = function(self)
	local Aliases = {}
	
	for Index = 1, #self.Names do 
		Aliases[Index] = PEG.Variable.Canonical(self.Names[Index])
	end
	
	local New = PEG.Sequence{
		PEG.Pattern"$", 
		PEG.Apply(
			PEG.Select(Aliases),
			function(Result) --TODO make not a closure
				Tools.Debug.Format"Result is currently %s"(Result)
				Tools.Debug.Push()
				if (OOP.Reflection.Type.Of(Box, Result)) then
					Result = Result()
				elseif (OOP.Reflection.Type.Of(Variable, Result) or OOP.Reflection.Type.Of(Incomplete, Result) or OOP.Reflection.Type.Of(Unboxer, Result)) then
					Result = Unboxer(Result)
				end
				Tools.Debug.Pop()
				Tools.Debug.Format"Alias result root is %s"(Result)
				return Result
			end
		)
	}
	return New
end;

local Copy = function(self)
	local Names = {}
	
	for Index = 1, #self.Names do local Name = self.Names[Index]
		Names[Index] = Name
	end
	
	local New = AliasList(Names)
	return New
end;

AliasList.Initialize = function(_, self, Names)
	self.Names = Names or {}
	self.Decompose = Decompose
	self.Copy = Copy
end;
return AliasList
