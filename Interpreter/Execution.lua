local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local OOP = require"Moonrise.OOP"

local Vlpeg = require"Sisyphus2.Vlpeg"

local Execution = {}

Execution.Resolvable = OOP.Declarator.Shortcuts"Sisyphus2.Interpreter.Execution.Resolvable" --TODO move this into Moonrise.Objects?

function Execution.Resolvable:Initialize(Instance)
end

function Execution.Resolvable:__call(...) error"Must be implemented" end

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

function Execution.ResolveArgument(Argument, Environment, CurrentArguments)
	local Return
	if OOP.Reflection.Type.Of(Execution.Resolvable, Argument) then
		Return = Argument(Environment)
	else
		Return = Argument
	end
	table.insert(CurrentArguments, Return)
end

function Execution.Incomplete:__call(Environment)
	local CurrentArguments = {}
	if #self.Arguments > 1 then
		for Index = 1, #self.Arguments do 
			local Argument = self.Arguments[Index]
			Execution.ResolveArgument(Argument, Environment, CurrentArguments)
		end
	else
		Execution.ResolveArgument(self.Arguments[1], Environment, CurrentArguments)
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

function Execution.Variable:Initialize(Instance, Location)
	print("Created ".. tostring(Instance) .." for ".. Location)
	Instance.Location = Location
end

function Execution.Variable:__call(Environment)
	return Environment.Variables[self.Location]
end

local function SetVariable(Environment, Parameters, Index, OldValues, Arguments)
	local Parameter = Parameters[Index]
	Environment.Variables[Parameter.Name] = Arguments[Index]
	OldValues[Parameter.Name] = Environment.Variables[Parameter.Name]
end

local function RestoreVariable(Environment, Parameters, Index, OldValues)
	local Parameter = Parameters[Index]
	Environment.Variables[Parameter.Name] = OldValues[Parameter.Name]
end

function Execution.Invoker(Parameters, Body) --NOTE not sure we can fix this NYI 
	local New = function(Environment, ...)
		local Arguments = {...}
		local OldValues = {}
		
		--for Index, Parameter in pairs(Parameters) do
		if #Parameters > 1 then
			for Index = 1,#Parameters do
				SetVariable(Environment, Parameters, Index, OldValues, Arguments)
			end
		else
			SetVariable(Environment, Parameters, 1, OldValues, Arguments)
		end
		
		local LastBody = Environment.Body
		Environment.Body = Body
			local Returns = Body(Environment)
		Environment.Body = LastBody

		if #Parameters > 1 then
			for Index = 1,#Parameters do
				RestoreVariable(Environment, Parameters, Index, OldValues)
			end
		else
			RestoreVariable(Environment, Parameters, 1, OldValues)
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
