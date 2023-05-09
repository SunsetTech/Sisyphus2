local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local OOP = require"Moonrise.OOP"

local Vlpeg = require"Sisyphus2.Vlpeg"

local Resolvable = OOP.Declarator.Shortcuts"resolvable" --TODO move this into Moonrise.Objects?

function Resolvable:Initialize(Instance, Resolve)
	print("Created ".. tostring(Instance) .." for ".. tostring(Resolve))
	Instance.Resolve = Resolve
end

function Resolvable:__call(...)
	local Return = self.Resolve(...)
	return Return
end

local Incomplete = OOP.Declarator.Shortcuts( --TODO this is a hack
	"incomplete", {
		Resolvable
	}
)

function Incomplete:Initialize(Instance, Arguments, Function)
	print("Created ".. tostring(Instance) .." for ".. tostring(Function))
	Instance.Arguments = Arguments
	Instance.Function = Function
end

local function Incomplete_LoopBody(Argument, Environment, CurrentArguments)
		local Return
		if OOP.Reflection.Type.Of(Resolvable, Argument) then
			Return = Argument(Environment)
		else
			Return = Argument
		end
		table.insert(CurrentArguments, Return)
end

function Incomplete:__call(Environment)
	local CurrentArguments = {}
	if #self.Arguments > 1 then
		for Index = 1, #self.Arguments do 
			local Argument = self.Arguments[Index]
			Incomplete_LoopBody(Argument, Environment, CurrentArguments)
		end
	else
		Incomplete_LoopBody(self.Arguments[1], Environment, CurrentArguments)
	end
	
	local Return = self.Function(table.unpack(CurrentArguments))
	return Return
end

local function Freeze_LoopBody(Arguments, Index)
	local Argument = Arguments[Index]
	
	if OOP.Reflection.Type.Of(Resolvable, Argument) then
		return true
	end
end

local Variable = OOP.Declarator.Shortcuts(
	"variable", {
		Resolvable
	}
)

function Variable:Initialize(Instance, Location)
	print("Created ".. tostring(Instance) .." for ".. Location)
	Instance.Location = Location
end

function Variable:__call(Environment)
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

local function Invoker(Parameters, Body) --NOTE not sure we can fix this NYI 
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

local Execution

Execution = {
	Resolvable = Resolvable;
	Incomplete = Incomplete; 
	Variable = Variable;
	Invoker = Invoker;
	Freeze = function(Function, Arguments)
		--local Arguments = {...} 
		
		local Incomplete = false
		if #Arguments > 1 then
			for Index = 1, #Arguments do
				--[[if not Incomplete then 
					Incomplete = Freeze_LoopBody(Arguments, Index)
				end]]
				Incomplete = not Incomplete and Freeze_LoopBody(Arguments, Index) or Incomplete
			end
		else
			Incomplete = Freeze_LoopBody(Arguments, 1)
		end
		
		local Return
		if Incomplete then
			Return = Execution.Incomplete(Arguments, Function)
		else
			Return = Function(table.unpack(Arguments)) --no incomplete arguments, simply apply and return
		end
		return Return
	end;

	Completable = function(Pattern, Function)
		--[[
			Helper function to define completable transformations.
			If any of the captured values from Pattern are of type "incomplete transform"
			the return value is also an incomplete transform that when called
			attempts to resolve all incomplete arguments, and then return the application of Function over all arguments
		]]
		local New = (Vlpeg.Constant(Function) * Vlpeg.Table(Pattern)) / Execution.Freeze
		return New
	end;
}

return Execution
