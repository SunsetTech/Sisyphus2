local lpeg = require"lpeg"

local OrderedMap = require"Moonrise.Object.OrderedMap"
local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Flat.Grammar : Sisyphus2.Structure.Object
---@operator call:Sisyphus2.Structure.Flat.Grammar
---@field Rules Moonrise.Object.OrderedMap
local Grammar = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Flat.Grammar", {
		require"Sisyphus2.Structure.Object"
	}
)

---@param self Sisyphus2.Structure.Flat.Grammar
local function Decompose(self)
	local Decomposed = lpeg.P(self.Rules.Pairs)
	return Decomposed
end; Grammar.Decompose = Decompose

---@param self Sisyphus2.Structure.Flat.Grammar
local function Copy(self)
	local Rules = OrderedMap()
	for Index = 1, self.Rules:NumKeys() do
		--local Name, Rule = self.Rules:GetPair(Index)
		Rules:Add(self.Rules:GetPair(Index))
	end
	local New = Grammar(nil, Rules)
	return New
end; Grammar.Copy = Copy

---@param self Sisyphus2.Structure.Flat.Grammar
---@param Name string
---@param Rule userdata
local function SetRule(self, Name, Rule)
	self.Rules:Add(Name, Rule)
end; Grammar.SetRule = SetRule

---@param self Sisyphus2.Structure.Flat.Grammar
---@param From Sisyphus2.Structure.Flat.Grammar
local function Merge(self, From)
	for Index = 1, From.Rules:NumKeys() do
		--local Name, Rule = From.Rules:GetPair(Index)
		self.Rules:Add(From.Rules:GetPair(Index))
	end
end; Grammar.Merge = Merge

---@param Instance Sisyphus2.Structure.Flat.Grammar
---@param Rules table<string,userdata>
---@param _Rules Moonrise.Object.OrderedMap
function Grammar:Initialize(Instance, Rules, _Rules)
	Instance.Rules = _Rules or OrderedMap(Rules)
	Instance.Decompose = Decompose
	Instance.Copy = Copy
	Instance.SetRule = SetRule
	Instance.Merge = Merge
end;

return Grammar
