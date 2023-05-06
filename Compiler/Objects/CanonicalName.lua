local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Compiler.Objects.CanonicalName:Sisyphus2.Compiler.Object
---@field Name string
---@field Namespace Sisyphus2.Compiler.Objects.CanonicalName?
local CanonicalName = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.CanonicalName", {
		require"Sisyphus2.Compiler.Object"
	}
)

local function Decompose(self, Reverse)
	return 
		self.Namespace 
		and (
			Reverse 
			and (self.Name ..".".. self.Namespace(Reverse))
			or (self.Namespace() ..".".. self.Name)
		) 
		or self.Name
end

local function Copy(self)
	return CanonicalName(self.Name, self.Namespace and self.Namespace:Copy() or nil)
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

---@param Instance Sisyphus2.Compiler.Objects.CanonicalName
---@param Name string
---@param Namespace Sisyphus2.Compiler.Objects.CanonicalName?
function CanonicalName:Initialize(Instance, Name, Namespace)
	Instance.Name = Name
	Instance.Namespace = Namespace or false
	Instance.Decompose = Decompose
	Instance.Copy = Copy
	Instance.Invert = Invert
end

return CanonicalName
