local OOP = require"Moonrise.OOP"

local Box = OOP.Declarator.Shortcuts"Box"

function Box:Initialize(Instance, Type, Value)
	Instance.Type = Type
	Instance.Value = Value
end

function Box:__tostring()
	return "Box<".. tostring(self.Value) ..">"
end

function Box:__call()
	return self.Value
end

return Box
