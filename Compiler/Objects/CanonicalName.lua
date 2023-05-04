local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Compiler.Objects.CanonicalName:Sisyphus2.Compiler.Object
---@field Name string
---@field Namespace Sisyphus2.Compiler.Objects.CanonicalName?
local CanonicalName = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.CanonicalName", {
		require"Sisyphus2.Compiler.Object"
	}
)

---@param Instance Sisyphus2.Compiler.Objects.CanonicalName
---@param Name string
---@param Namespace Sisyphus2.Compiler.Objects.CanonicalName?
function CanonicalName:Initialize(Instance, Name, Namespace)
	Instance.Name = Name
	Instance.Namespace = Namespace
end

function CanonicalName:Decompose()
	return self.Namespace and (self.Namespace() ..".".. self.Name) or self.Name
end

function CanonicalName:Copy()
	return CanonicalName(self.Name, self.Namespace and -self.Namespace or nil)
end

function CanonicalName:Invert()
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

return CanonicalName
