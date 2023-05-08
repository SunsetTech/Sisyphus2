local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.CanonicalName:Sisyphus2.Structure.Object
---@field Name string
---@field Namespace Sisyphus2.Structure.CanonicalName?
local CanonicalName = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.CanonicalName", {
		require"Sisyphus2.Structure.Object"
	}
)


--Courtesy GPT4
local function Decompose(self, Reverse)
    local Ret = ""
    local current = self
    local separator = ""

    while current do
        if Reverse then
            Ret = Ret .. separator .. current.Name
        else
            Ret = current.Name .. separator .. Ret
        end

        separator = "."
        current = current.Namespace
    end

    return Ret
end

local function Copy(self)
	local New = CanonicalName(self.Name, self.Namespace and self.Namespace:Copy() or nil)
	return New
end

local function Invert(self)
	local At = self
	local Inverted = CanonicalName(At.Name)
	---@diagnostic disable-next-line:need-check-nil LLS is wrong here
	while At.Namespace do
		At = At.Namespace
		---@diagnostic disable-next-line:need-check-nil and here
		Inverted = CanonicalName(At.Name, Inverted)
	end
	return Inverted
end

---@param Instance Sisyphus2.Structure.CanonicalName
---@param Name string
---@param Namespace Sisyphus2.Structure.CanonicalName?
function CanonicalName:Initialize(Instance, Name, Namespace)
	Instance.Name = Name
	Instance.Namespace = Namespace or false
	Instance.Decompose = Decompose
	Instance.Copy = Copy
	Instance.Invert = Invert
end

return CanonicalName
