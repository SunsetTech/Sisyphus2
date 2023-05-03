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

return CanonicalName
--local Import = require"Moonrise.Import"


--local Object = Import.Module.Relative"Object"

--[[return Object(
	"CanonicalName", {
		Construct = function(self, Name, Namespace)
			--Error.CallerAssert(type(Name) == "string", "Need a string for Name")
			
			self.Name = Name
			self.Namespace = Namespace
		end;
		Decompose = function(self)
			return
				self.Namespace
				and self.Namespace() ..".".. self.Name
				or self.Name
		end;
		Copy = function(self)
			return self.Name, self.Namespace and -self.Namespace or nil
		end;
	}
)]]
