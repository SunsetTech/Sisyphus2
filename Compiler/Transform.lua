local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local OOP = require"Moonrise.OOP"

local Vlpeg = require"Sisyphus2.Vlpeg"

local Resolvable = OOP.Declarator.Shortcuts"resolvable" --TODO move this into Moonrise.Objects?

function Resolvable:Initialize(Instance, Resolve)
	Instance.Resolve = Resolve
end

function Resolvable:__call(...)
	return self.Resolve(...)
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

function Incomplete:__call(Environment)
	--Tools.Error.CallerAssert(type(Environment) == "table", "oops")
	local CurrentArguments = {}
	--for Index, Argument in pairs(Arguments) do
	for Index = 1, #self.Arguments do local Argument = self.Arguments[Index]
		local Type = type(Argument)
		local Returns
		if Type == "resolvable" then
			Returns = {Argument(Environment)}
		else
			Returns = {Argument}
		end
		--for _, Return in pairs(Returns) do
		for ReturnIndex = 1, #Returns do
			local Return = Returns[ReturnIndex]
			table.insert(CurrentArguments, Return)
		end
	end
	return self.Function(table.unpack(CurrentArguments))
end

local Transform

Transform = {
	Resolvable = Resolvable;
	
	Incomplete = function(Arguments, Function)
		return Transform.Resolvable(Incomplete(Arguments, Function))
	end;

	Freeze = function(Function, ...)
		local Arguments = {...} 
		
		local Incomplete = false
		for Index = 1, #Arguments do
			local Argument = Arguments[Index]
			local Type = type(Argument)
			
			if Type == "resolvable" then
				Incomplete = true
				break
			end
		end
		
		if Incomplete then
			local Return = Transform.Incomplete(Arguments, Function)
			return Return
		else
			return Function(table.unpack(Arguments)) --no incomplete arguments, simply apply and return
		end
	end;

	Completable = function(Pattern, Function)
		--[[
			Helper function to define completable transformations.
			If any of the captured values from Pattern are of type "incomplete transform"
			the return value is also an incomplete transform that when called
			attempts to resolve all incomplete arguments, and then return the application of Function over all arguments
		]]
		return (Vlpeg.Constant(Function) * Pattern) / Transform.Freeze
	end;
}

return Transform
