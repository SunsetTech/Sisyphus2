local Namer = require"Sisyphus2.Compiler.Objects.Namer"
local Merger = require"Sisyphus2.Compiler.Objects.Merger"
local Flat = require"Sisyphus2.Compiler.Objects.Flat"
local Nested = {
	Rule = require"Sisyphus2.Compiler.Objects.Nested.Rule"
}

local OOP = require"Moonrise.OOP"

local Grammar = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.Grammar", {
		require"Sisyphus2.Compiler.Object"
	}
)

Grammar.Initialize = function(_, self, Rules, Base, _Rules)
	if _Rules then
		self.Rules = _Rules
	else
		self.Rules = Namer({"Nested.Grammar", "Nested.Rule"}, Rules)
	end
	self.Base = Base or Flat.Grammar()
end;

Grammar.Decompose = function(self, Canonical)
	local ConvertedRules = Namer({"Nested.Grammar", "Nested.Rule"})
	for NameIndex = 1, self.Rules.Entries:NumKeys() do
		local Name,Rule = self.Rules.Entries:GetPair(NameIndex)
		if Rule%"Nested.PEG" then
			ConvertedRules.Entries:Add(Name,Nested.Rule(Rule))
		elseif Rule%"Nested.Grammar" or Rule%"Nested.Rule" then
			ConvertedRules.Entries:Add(Name, Rule)
		end
	end
	
	local Flattened = Merger("Flat.Grammar", ConvertedRules(Canonical))()
	
	return 
		Flattened
		and self.Base + Flattened
		or self.Base
end;


Grammar.Copy = function(self)
	local Instance = Grammar(nil, -self.Base, -self.Rules)
	return Instance
end;

Grammar.Merge = function(Into, From)
	if From.Base then
		if Into.Base then
			--Into.Base = Into.Base + From.Base
			Into.Base:Merge(From.Base)
		else
			Into.Base = From.Base
		end
	end
	--Into.Rules = Namer({"Nested.Grammar", "Nested.Rule"}) + {Into.Rules, From.Rules}
	Into.Rules:Merge(From.Rules)
end;

return Grammar
