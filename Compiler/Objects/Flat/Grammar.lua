local lpeg = require"lpeg"

local OrderedMap = require"Moonrise.Object.OrderedMap"
local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Compiler.Objects.Flat.Grammar : Sisyphus2.Compiler.Object
---@operator call:Sisyphus2.Compiler.Objects.Flat.Grammar
---@field Rules Moonrise.Object.OrderedMap
local Grammar = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Flat.Grammar", {
		require"Sisyphus2.Compiler.Object"
	}
)

function Grammar:Initialize(Instance, Rules, _Rules)
	Instance.Rules = _Rules or OrderedMap(Rules)
end;

function Grammar:Decompose()
	return lpeg.P(self.Rules.Pairs)
end;

function Grammar:Copy()
	local Rules = OrderedMap{}
	for Index = 1, self.Rules:NumKeys() do
		local Name, Rule = self.Rules:GetPair(Index)
		Rules:Add(Name, Rule)
	end
	return Grammar(nil, Rules)
end;
		
function Grammar:SetRule(Name, Rule)
	self.Rules:Add(Name, Rule)
end;

---@param From Sisyphus2.Compiler.Objects.Flat.Grammar
function Grammar:Merge(From)
	for Index = 1, From.Rules:NumKeys() do
		local Name, Rule = From.Rules:GetPair(Index)
		self.Rules:Add(Name, Rule)
	end
end

return Grammar
--[=[return Object(
	"Flat.Grammar", {
		Construct = function(self, Rules, Names, InNames)
			--print_callstack()
			self.Rules = Rules or {}
			self.Names = Names or {}
			self.InNames = InNames or {}
			if not Names then
				for Name in pairs(Rules or {}) do
					self.InNames[Name] = true
					table.insert(self.Names, Name)
				end
			end
		end;

		Decompose = function(self)
			return lpeg.P(self.Rules)
		end;

		Copy = function(self)
			local Rules, Names, InNames = {},{},{}
			for NameIndex = 1, #self.Names do
				local Name = self.Names[NameIndex]
				local Rule = self.Rules[Name]
				Rules[Name] = Rule
				Names[NameIndex] = Name
				InNames[Name] = true
			end
			return Rules, Names, InNames
			--return Tools.Table.Copy(self.Rules)
		end,
		
		SetRule = function(self, Name, Rule)
			if not self.InNames[Name] then
				table.insert(self.Names, Name)
				self.InNames[Name] = true
			end
			self.Rules[Name] = Rule
		end;
		
		Merge = function(Into, From)
			for NameIndex = 1, #From.Names do
				local Name = From.Names[NameIndex]
				local Rule = From.Rules[Name]
				if not Into.InNames[Name] then
					table.insert(Into.Names, Name)
					Into.InNames[Name] = true
				end
				Into.Rules[Name] = Rule
			end
			--[[for Name, Rule in pairs(From.Rules) do
				Tools.Error.CallerAssert(Into.Rules[Name] == nil, "Cant overwrite existing rule ".. Name,1)
				Into.Rules[Name] = Rule
			end]]
		end
	}
);]=]
