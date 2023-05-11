local OOP = require"Moonrise.OOP"
local Resolvable = OOP.Declarator.Shortcuts"Sisyphus2.Interpreter.Execution.Resolvable" --TODO move this into Moonrise.Objects?

function Resolvable:Initialize()
end

function Resolvable:__call() error"Must be implemented" end

return Resolvable

