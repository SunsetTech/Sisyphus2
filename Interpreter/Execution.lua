local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local OOP = require"Moonrise.OOP"

local Vlpeg = require"Sisyphus2.Vlpeg"

local Resolvable = OOP.Declarator.Shortcuts"resolvable" --TODO move this into Moonrise.Objects?

function Resolvable:Initialize(Instance, Resolve)
	Instance.Resolve = Resolve
end

function Resolvable:__call(...)
	local Return = self.Resolve(...)
	return Return
end

local Incomplete = OOP.Declarator.Shortcuts"incomplete"

function Incomplete:Initialize(Instance, Arguments, Function)
	Instance.Arguments = Arguments
	Instance.Function = Function
end

local LazyValue = OOP.Declarator.Shortcuts"lazyvalue"
function LazyValue:Initialize(Instance, Value)
	Instance.Value = Value
end;
function LazyValue:__call()
	return self.Value
end

local function Incomplete_LoopBody(Argument, Environment, CurrentArguments)
		local Return
		if type(Argument) == "resolvable" then
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
	
	if type(Argument) == "resolvable" then
		return true
	end
end

local Transform

Transform = {
	Resolvable = Resolvable;
	
	Incomplete = function(Arguments, Function)
		local New = Transform.Resolvable(Incomplete(Arguments, Function))
		return New
	end;

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
			Return = Transform.Incomplete(Arguments, Function)
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
		local New = (Vlpeg.Constant(Function) * Vlpeg.Table(Pattern)) / Transform.Freeze
		return New
	end;
}

return Transform
