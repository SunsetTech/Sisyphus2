local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local OOP = require"Moonrise.OOP"

local Definition = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Template.Definition", {
		require"Sisyphus2.Compiler.Object"
	}
)

Definition.Initialize = function(_, self, Basetype, _Definition)
	self.Basetype = Basetype
	self.Definition = _Definition
	self.Decompose = Definition.Decompose
end;

Definition.Decompose = function(self)
	return self.Definition
end;

Definition.Copy = function(self)
	return Definition(self.Basetype, -self.Definition)
end

return Definition
