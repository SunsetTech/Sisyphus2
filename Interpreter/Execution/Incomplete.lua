local Tools = require"Moonrise.Tools"
local OOP = require"Moonrise.OOP"

local Lazy = require"Sisyphus2.Interpreter.Execution.Lazy"
local Recursive = require"Sisyphus2.Interpreter.Execution.Recursive"
local Variable = require"Sisyphus2.Interpreter.Execution.Variable"

local function ArgumentsToString(Arguments)
	local Parts = {}
	--for k,v in pairs(Arguments) do
	for Index = 1, #Arguments do
		local v = Arguments[Index]
		table.insert(Parts, tostring(v))
	end
	return table.concat(Parts, ", ")
end

local Incomplete = OOP.Declarator.Shortcuts( --TODO this is a hack
	"Incomplete", {
		require"Sisyphus2.Interpreter.Execution.Resolvable"
	}
)

local OldTostring = Incomplete.__tostring

function Incomplete:__tostring()
	return tostring(self.Function) ..'('.. ArgumentsToString(self.Arguments) ..")"
end

function Incomplete:Initialize(Instance, Arguments, Function)
	Instance.Arguments = Arguments
	Instance.Function = Function
	Tools.Debug.Print("Created ".. tostring(Instance) .." for ".. tostring(Function))
end

local function ConvertToLazy(Argument, Environment, CurrentArguments)
	if (
		OOP.Reflection.Type.Of(Incomplete, Argument) 
		or OOP.Reflection.Type.Of(Variable, Argument)
		or OOP.Reflection.Type.Of(Recursive, Argument)
	) then
		Argument = Lazy(Argument, Environment)
	end
	table.insert( CurrentArguments, Argument)
end

function Incomplete:__call(Environment)
	Tools.Debug.Format"Completing %s"(self.Function)
	Tools.Debug.Push()
	local CurrentArguments = {}
	if #self.Arguments > 1 then
		for Index = 1, #self.Arguments do 
			local Argument = self.Arguments[Index]
			ConvertToLazy(Argument, Environment, CurrentArguments)
		end
	else
		ConvertToLazy(self.Arguments[1], Environment, CurrentArguments)
	end
	
	local Return = self.Function(table.unpack(CurrentArguments))
	Tools.Debug.Pop()
	Tools.Debug.Format"%s->%s"(self.Function, Return)
	return Return
end

return Incomplete
