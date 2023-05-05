local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local Package

Package = {
	Resolvable = function(Resolve)
		return setmetatable(
			{},
			{
				__type = "resolvable";
				__tostring = function()
					return Tools.String.Format"Resolvable(%s)"(Resolve)
				end;
				__call = function(self,...)
					return Resolve(...)
				end;
			}
		)
	end;
	
	Incomplete = function(Arguments, Function)
		return Package.Resolvable(
			function(Environment)
				--Tools.Error.CallerAssert(type(Environment) == "table", "oops")
				local CurrentArguments = {}
				--for Index, Argument in pairs(Arguments) do
				for Index = 1, #Arguments do local Argument = Arguments[Index]
					local Type = type(Argument)
					local Returns
					if Type == "resolvable" then
						Returns = {Argument(Environment)}
						if (type(Returns[1]) == "table") then
							print(table.unpack(Returns[1]))
						end
					else
						Returns = {Argument}
					end
					--for _, Return in pairs(Returns) do
					for ReturnIndex = 1, #Returns do
						local Return = Returns[ReturnIndex]
						table.insert(CurrentArguments, Return)
					end
				end
				return Function(table.unpack(CurrentArguments))
			end
		)
	end;

	Completable = function(Pattern, Function)
		--[[
			Helper function to define completable transformations.
			If any of the captured values from Pattern are of type "incomplete transform"
			the return value is also an incomplete transform that when called
			attempts to resolve all incomplete arguments, and then return the application of Function over all arguments
		]]
		return Pattern / function(...)
			local Arguments = {...} 
			
			local Incomplete = false
			--for Index, Argument in pairs(Arguments) do --search for incomplete arguments
			for Index = 1, #Arguments do
				local Argument = Arguments[Index]
				local Type = type(Argument)
				
				if Type == "resolvable" then
					Incomplete = true
					break
				end
			end
			
			if Incomplete then
				return Package.Incomplete(Arguments, Function)
			else
				return Function(table.unpack(Arguments)) --no incomplete arguments, simply apply and return
			end
		end
	end;
}

return Package
