local OOP = require"Moonrise.OOP"
local Resolvable = OOP.Declarator.Shortcuts"Resolvable" --TODO move this into Moonrise.Objects?

function Resolvable:Initialize()
end

function Resolvable:__call() error"Must be implemented" end

return Resolvable

