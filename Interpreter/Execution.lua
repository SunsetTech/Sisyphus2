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

function Execution.Resolvable:Initialize()
end

function Execution.Resolvable:__call() error"Must be implemented" end

Execution.Lazy = OOP.Declarator.Shortcuts(
	"Sisyphus2.Interpreter.Execution.Lazy", {
		Execution.Resolvable
	}
)

function Execution.Lazy:Initialize(Instance, Inner, Environment)
	Instance.Inner = Inner
	Instance.Environment = Environment
end

function Execution.Lazy:__call()
	Tools.Debug.Format"Finishing %s"(self)
	Tools.Debug.Push()
	local Result = self.Inner(self.Environment)
	if (OOP.Reflection.Type.Of(Execution.Recursive, Result)) then --TODO this is a hack and I think wont work right in certain cases
		Result = Execution.Lazy(Result, self.Environment)
	end
	Tools.Debug.Pop()
	Tools.Debug.Format"%s -> %s"(self, Result)
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
	Instance.Arguments = Arguments
	Instance.Function = Function
	Tools.Debug.Print("Created ".. tostring(Instance) .." for ".. tostring(Function))
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
	return "Variable[".. tostring(self.Location) .."]"
end

function Execution.Variable:Initialize(Instance, Location)
	Instance.Location = Location
	Tools.Debug.Format"Created %s"(Instance)
end

function Execution.Variable:__call(Environment)
	return Environment.Variables[self.Location]
end

function Execution.SetVariable(Environment, Parameters, Index, OldValues, Arguments)
	local Parameter = Parameters[Index]
	Environment.Variables[Parameter.Name] = Arguments[Index]
	OldValues[Parameter.Name] = Environment.Variables[Parameter.Name]
	Tools.Debug.Format"Set variable %s to %s"(Parameter.Name, Arguments[Index])
end

function Execution.RestoreVariable(Environment, Parameters, Index, OldValues)
	local Parameter = Parameters[Index]
	Environment.Variables[Parameter.Name] = OldValues[Parameter.Name]
end

function Execution.Invoker(Parameters, Body) --NOTE not sure we can fix this NYI 
	local New = function(Environment, ...) --TODO make onesided. also figure out why Environment is stored in the args table
		Tools.Debug.Format"Env=%s"(Environment)
		Tools.Debug.Format"Invoking %s"(Body)
		Tools.Debug.Push()
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
		Tools.Debug.Pop()
		Tools.Debug.Format"Returning %s from %s"(Returns, Body)
		return Returns
	end
	Tools.Debug.Format"Created invoker_%s for %s"(New, Body)
	return New
end

local function ArgumentsToString(Arguments)
	local Parts = {}
	for k,v in pairs(Arguments) do
		table.insert(Parts, tostring(v))
	end
	return table.concat(Parts, ", ")
end

Execution.Freeze = function(Function, Arguments)
	Tools.Debug.Format"Checking %s(%s) for frozen elements"(Function, ArgumentsToString(Arguments))
	Tools.Debug.Push()
	local Incomplete = false
	if #Arguments > 1 then
		for Index = 1, #Arguments do
			Incomplete = not Incomplete and Execution.IsResolvable(Arguments, Index) or Incomplete
		end
	else
		Incomplete = Execution.IsResolvable(Arguments, 1)
	end
	
	local Return
	Tools.Debug.Pop()
	if Incomplete then
		Return = Execution.Incomplete(Arguments, Function)
		Tools.Debug.Format"Found frozen elements for %s(%s), froze into %s"(Function,ArgumentsToString(Arguments),Return)
	else
		Return = Function(table.unpack(Arguments)) --no incomplete arguments, simply apply and return
		Tools.Debug.Format"No frozen elements for %s(%s), called and got %s"(Function, ArgumentsToString(Arguments), Return)
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
