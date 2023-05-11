local OOP = require"Moonrise.OOP"

local NamedFunction = OOP.Declarator.Shortcuts"Sisyphus2.Interpreter.Execution.NamedFunction"

function NamedFunction:Initialize(Instance, Name, Function)
	Instance.Name = Name
	Instance.Function = Function
end

function NamedFunction:__call(...)
	return self.Function(...)
end

function NamedFunction:__tostring()
	return self.Name
end

return NamedFunction
