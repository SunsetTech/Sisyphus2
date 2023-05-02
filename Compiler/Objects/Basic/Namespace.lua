local Map = require"Sisyphus2.Compiler.Objects.Map"
local Nested = require"Sisyphus2.Compiler.Objects.Nested"

local OOP = require"Moonrise.OOP"

local Namespace = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Basic.Namespace", {
		require"Sisyphus2.Compiler.Object"
	}
)


Namespace.Initialize = function(_, self, Children, _Children)
	if _Children then 
		self.Children = _Children
	else
		self.Children = Map({"Basic.Namespace", "Basic.Type.Definition", "Basic.Type.Set"},Children or {})
	end
end;

Namespace.Decompose = function(self) --into a Nested.Grammar
	return 
		Nested.Grammar(self.Children())
end;

Namespace.Copy = function(self)
	return Namespace(nil, (-self.Children))
end;

Namespace.Merge = function(Into, From)
	Into.Children = Map({"Basic.Namespace","Basic.Type.Definition","Basic.Type.Set"},{}) + {Into.Children, From.Children}
end;

return Namespace
