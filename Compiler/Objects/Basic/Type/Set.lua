local Import = require"Moonrise.Import"

local Map = Import.Module.Relative"Objects.Map"
local Nested = Import.Module.Relative"Objects.Nested"
local PEG = Nested.PEG
local Variable = PEG.Variable

local OOP = require"Moonrise.OOP"

local Set = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Basic.Type.Set", {
		require"Sisyphus2.Compiler.Object"
	}
)

Set.Initialize = function(_, self, Children, _Children)
	if _Children then 
		self.Children = _Children
	else
		self.Children = Map({"Basic.Type.Definition", "Basic.Type.Set"}, Children or {})
	end
end;

Set.Decompose = function(self)
	local Options = {}
	
	for Name, _ in pairs(self.Children.Entries) do
		table.insert(Options, Variable.Child(Name))
	end
	
	return 
		Nested.Grammar{
			PEG.Select(Options)
		}
		+ Nested.Grammar(self.Children())
end;

Set.Copy = function(self)
	return Set(nil, (-self.Children))
end;

return Set
