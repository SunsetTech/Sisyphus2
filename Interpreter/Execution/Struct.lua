local OOP = require"Moonrise.OOP"

local Struct = OOP.Declarator.Shortcuts(
	"Struct", {
		require"Sisyphus2.Interpreter.Execution.Box"
	}
)

function Struct:Initialize(Instance, Type, Value, Fields)
	Struct.Parents.Box:Initialize(Instance, Type, Value)
	Instance.Fields = Fields
end

local function FieldsToString(Fields)
	local Parts = {}
	for K, V in pairs(Fields) do
		table.insert(Parts, tostring(K) ..": ".. tostring(V))
	end
	return table.concat(Parts, "; ")
end

function Struct:__tostring()
	return self.Type .."(".. tostring(self.Value) .."){".. FieldsToString(self.Fields) .."}"
end

return Struct
