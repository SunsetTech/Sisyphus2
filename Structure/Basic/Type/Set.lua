local Import = require"Moonrise.Import"

local OrderedMap = require"Moonrise.Object.OrderedMap"

local Map = Import.Module.Relative"Map"
local Nested = Import.Module.Relative"Nested"
local PEG = Nested.PEG
local Variable = PEG.Variable

local OOP = require"Moonrise.OOP"

local Set = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Basic.Type.Set", {
		require"Sisyphus2.Structure.Object"
	}
)

Set.Initialize = function(_, self, Children, _Children)
	if _Children then 
		self.Children = _Children
	else
		self.Children = Map({"Basic.Type.Definition", "Basic.Type.Set"}, Children or {})
	end
	self.Decompose = Set.Decompose
end;

local GetPair = OrderedMap.GetPair
local NumKeys = OrderedMap.NumKeys
local Add = OrderedMap.Add

Set.Decompose = function(self)
	local Options = {}
	
	--for Name, _ in pairs(self.Children.Entries) do
	local Grammar = Nested.Grammar()
	for Index = 1, self.Children.Entries:NumKeys() do
		local Name,Entry = GetPair(self.Children.Entries, Index)
		Add(Grammar.Rules.Entries, Name, Entry:Decompose())
		table.insert(Options, Variable.Child(Name))
	end
	Options = PEG.Select(Options)
	Add(Grammar.Rules.Entries, 1,Options)
	return 
		Grammar
		--+ Nested.Grammar(self.Children())
end;

Set.Copy = function(self)
	local Copy = Set(nil, self.Children:Copy())
	return Copy
end;

return Set
