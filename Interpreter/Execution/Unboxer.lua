local OOP = require"Moonrise.OOP"

local Box = require"Sisyphus2.Interpreter.Execution.Box"

local Unboxer = OOP.Declarator.Shortcuts(
	"Unboxer", {
		require"Sisyphus2.Interpreter.Execution.Resolvable"
	}
)

function Unboxer:Initialize(Instance, Inner)
	Instance.Inner = Inner
end

function Unboxer:__tostring()
	return "Unboxer<".. tostring(self.Inner) ..">"
end

function Unboxer:__call(...)
	local Result = self.Inner(...)
	assert(OOP.Reflection.Type.Of(Box, Result))
	Result = Result()
	return Result
end

return Unboxer
