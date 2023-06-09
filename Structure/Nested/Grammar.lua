local Namer = require"Sisyphus2.Structure.Namer"
local Merger = require"Sisyphus2.Structure.Merger"
local Flat = require"Sisyphus2.Structure.Flat"
local Nested = {
	Rule = require"Sisyphus2.Structure.Nested.Rule"
}

local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Nested.Grammar : Sisyphus2.Structure.Object
---@operator call:Sisyphus2.Structure.Nested.Grammar
---@field Rules Sisyphus2.Structure.Namer
---@field Base Sisyphus2.Structure.Flat.Grammar
local Grammar = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.Grammar", {
		require"Sisyphus2.Structure.Object"
	}
)

local Decompose = function(self, Canonical)
	local ConvertedRules = Namer({"Nested.Grammar", "Nested.Rule"})
	for NameIndex = 1, self.Rules.Entries:NumKeys() do
		local Name,Rule = self.Rules.Entries:GetPair(NameIndex)
		if Rule%"Nested.PEG" then
			ConvertedRules.Entries:Add(Name,Nested.Rule(Rule))
		elseif Rule%"Nested.Grammar" or Rule%"Nested.Rule" then
			ConvertedRules.Entries:Add(Name, Rule)
		end
	end
	
	local Flattened = Merger("Flat.Grammar", ConvertedRules:Decompose(Canonical))
	Flattened = Flattened:Decompose()
	--local Base = 
	return 
		Flattened
		and self.Base + Flattened
		or self.Base
end;


local Copy = function(self)
	local New = Grammar(nil, self.Base:Copy(), self.Rules:Copy())
	return New
end;

local Merge = function(self, From)
	if From.Base then
		if self.Base then
			--Into.Base = Into.Base + From.Base
			self.Base:Merge(From.Base)
		else
			self.Base = From.Base
		end
	end
	--Into.Rules = Namer({"Nested.Grammar", "Nested.Rule"}) + {Into.Rules, From.Rules}
	self.Rules:Merge(From.Rules)
end;

Grammar.Initialize = function(_, self, Rules, Base, _Rules)
	if _Rules then
		self.Rules = _Rules
	else
		self.Rules = Namer({"Nested.Grammar", "Nested.Rule"}, Rules)
	end
	self.Base = Base or Flat.Grammar()
	self.Decompose = Decompose
	self.Copy = Copy
	self.Merge = Merge
end;

return Grammar
