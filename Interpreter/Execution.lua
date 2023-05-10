local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local OOP = require"Moonrise.OOP"

local Vlpeg = require"Sisyphus2.Vlpeg"

local Execution = {}

Execution.NamedFunction = OOP.Declarator.Shortcuts"Sisyphus2.Interpreter.Execution.NamedFunction"

function Execution.NamedFunction:Initialize(Instance, Name, Function)
	Instance.Name = Name
	Instance.Function = Function
end

function Execution.NamedFunction:__call(...)
	return self.Function(...)
end

function Execution.NamedFunction:__tostring()
	return self.Name
end

Execution.Resolvable = OOP.Declarator.Shortcuts"Sisyphus2.Interpreter.Execution.Resolvable" --TODO move this into Moonrise.Objects?

function Execution.Resolvable:Initialize(Instance)
end

function Execution.Resolvable:__call(...) error"Must be implemented" end

Execution.Lazy = OOP.Declarator.Shortcuts(
	"Sisyphus2.Interpreter.Execution.Lazy", {
		Execution.Resolvable
	}
)

function Execution.Lazy:Initialize(Instance, Inner, Environment)
	print("Created ".. tostring(Instance) .." for ".. tostring(Inner))
	Instance.Inner = Inner
	Instance.Environment = Environment
end

function Execution.Lazy:__call()
	local Result = self.Inner(self.Environment)
	if (OOP.Reflection.Type.Of(Execution.Recursive, Result)) then
		Result = Execution.Lazy(Result, self.Environment)
	end
	print(self, "got", Result)
	return Result
end

function Execution.ResolveArgument(Argument)
	while OOP.Reflection.Type.Of(Execution.Lazy, Argument) do
		Argument = Argument()
	end
	
	return Argument
end

Execution.Recursive = OOP.Declarator.Shortcuts(
	"Sisyphus2.Interpreter.Execution.Recursive", {
		Execution.Resolvable
	}
)

function Execution.Recursive:Initialize(Instance, Function)
	Instance.Function = Function
end

function Execution.Recursive:__call(Environment)
	if not Environment then
		Tools.Debug.PrintStack()
		assert(Environment)
	end
	return self.Function(Environment.Body)
end

Execution.Incomplete = OOP.Declarator.Shortcuts( --TODO this is a hack
	"Sisyphus2.Interpreter.Execution.Incomplete", {
		Execution.Resolvable
	}
)

function Execution.Incomplete:Initialize(Instance, Arguments, Function)

	print("Created ".. tostring(Instance) .." for ".. tostring(Function))
	Instance.Arguments = Arguments
	Instance.Function = Function
end

function Execution.ConvertToLazy(Argument, Environment, CurrentArguments)
	table.insert(
		CurrentArguments,
		(
			OOP.Reflection.Type.Of(Execution.Incomplete, Argument) 
			or OOP.Reflection.Type.Of(Execution.Variable, Argument)
			or OOP.Reflection.Type.Of(Execution.Recursive, Argument)
		)
		and Execution.Lazy(Argument, Environment)
		or Argument
	)
end

function Execution.Incomplete:__call(Environment)
	local CurrentArguments = {}
	if #self.Arguments > 1 then
		for Index = 1, #self.Arguments do 
			local Argument = self.Arguments[Index]
			Execution.ConvertToLazy(Argument, Environment, CurrentArguments)
		end
	else
		Execution.ConvertToLazy(self.Arguments[1], Environment, CurrentArguments)
	end
	
	local Return = self.Function(table.unpack(CurrentArguments))
	return Return
end

function Execution.IsResolvable(Arguments, Index)
	local Argument = Arguments[Index]
	return OOP.Reflection.Type.Of(Execution.Resolvable, Argument)
end

Execution.Variable = OOP.Declarator.Shortcuts(
	"Sisyphus2.Interpreter.Execution.Variable", {
		Execution.Resolvable
	}
)

local OldTostring = Execution.Variable.__tostring
function Execution.Variable:__tostring()
	return OldTostring(self) .."[".. tostring(self.Location) .."]"
end

function Execution.Variable:Initialize(Instance, Location)
	Instance.Location = Location
	print("Created ".. tostring(Instance) .." for ".. Location)
end

function Execution.Variable:__call(Environment)
	return Environment.Variables[self.Location]
end

function Execution.SetVariable(Environment, Parameters, Index, OldValues, Arguments)
	local Parameter = Parameters[Index]
	Environment.Variables[Parameter.Name] = Arguments[Index]
	OldValues[Parameter.Name] = Environment.Variables[Parameter.Name]
end

function Execution.RestoreVariable(Environment, Parameters, Index, OldValues)
	local Parameter = Parameters[Index]
	Environment.Variables[Parameter.Name] = OldValues[Parameter.Name]
end

function Execution.Invoker(Parameters, Body) --NOTE not sure we can fix this NYI 
	local New = function(Environment, ...) --TODO make onesided
		local Arguments = {...}
		local OldValues = {}
		
		--for Index, Parameter in pairs(Parameters) do
		if #Parameters > 1 then
			for Index = 1,#Parameters do
				Execution.SetVariable(Environment, Parameters, Index, OldValues, Arguments)
			end
		else
			Execution.SetVariable(Environment, Parameters, 1, OldValues, Arguments)
		end
		
		local LastBody = Environment.Body
		Environment.Body = Body
			local Returns = Body(Environment)
		Environment.Body = LastBody

		if #Parameters > 1 then
			for Index = 1,#Parameters do
				Execution.RestoreVariable(Environment, Parameters, Index, OldValues)
			end
		else
			Execution.RestoreVariable(Environment, Parameters, 1, OldValues)
		end
		
		return Returns
	end
	print("Created invoker_".. tostring(New) .." for ".. tostring(Body))
	return New
end


Execution.Freeze = function(Function, Arguments)
	--local Arguments = {...} 
	
	local Incomplete = false
	if #Arguments > 1 then
		for Index = 1, #Arguments do
			--[[if not Incomplete then 
				Incomplete = Freeze_LoopBody(Arguments, Index)
			end]]
			Incomplete = not Incomplete and Execution.IsResolvable(Arguments, Index) or Incomplete
		end
	else
		Incomplete = Execution.IsResolvable(Arguments, 1)
	end
	
	local Return
	if Incomplete then
		Return = Execution.Incomplete(Arguments, Function)
	else
		Return = Function(table.unpack(Arguments)) --no incomplete arguments, simply apply and return
	end
	return Return
end;

Execution.Completable = function(Pattern, Function)
	--[[
		Helper function to define completable transformations.
		If any of the captured values from Pattern are of type "incomplete transform"
		the return value is also an incomplete transform that when called
		attempts to resolve all incomplete arguments, and then return the application of Function over all arguments
	]]
	local New = (Vlpeg.Constant(Function) * Vlpeg.Table(Pattern)) / Execution.Freeze
	return New
end;

return Execution
