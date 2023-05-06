local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local OrderedMap = require"Moonrise.Object.OrderedMap"

local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Compiler.Objects.Map2:Sisyphus2.Compiler.Object
---@operator call:Sisyphus2.Compiler.Objects.Map2
---@field Types string[]
---@field Entries Moonrise.Object.OrderedMap
local Map2 = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Map2", {
		require"Sisyphus2.Compiler.Object"
	}
)

Map2.Initialize = function(_, self, Types, Entries, _Entries)
	--print_caller_info()
	self.Types =
		type(Types) == "string"
		and {Types}
		or Types
	--self.Entries = setmetatable(Entries, {__newindex=function(_,k,v) print(k,v) print_caller_info() rawset(Entries, k, v) end;})
	self.Entries = _Entries or OrderedMap(Entries)
	self.Add = Map2.Add
	self.Decompose = Map2.Decompose
	self.Copy = Map2.Copy
	self.Merge = Map2.Merge
end;

Map2.Add = function(self, Key, Value)
	self.Entries:Add(Key, Value)
end;

Map2.Decompose = function(self)
	local Decomposed = {}

	--for Key, Entry in pairs(self.Entries) do
	for Index = 1, self.Entries:NumKeys() do
		local Key, Entry = self.Entries:GetPair(Index)
		local TypeCheck = false
		--for _, Type in pairs(self.Types) do
		--[[for TypeIndex = 1, #self.Types do
			local Type = self.Types[TypeIndex]
			if Entry%Type then
				TypeCheck = true
				break
			end
		end
		assert(TypeCheck)]]
		Decomposed[Key] = Entry()
	end

	return Decomposed
end;

Map2.Copy = function(self)
	local EntriesCopy = OrderedMap()
	--for Name, Entry in pairs(self.Entries) do
	for Index = 1, self.Entries:NumKeys() do
		local Name, Entry = self.Entries:GetPair(Index)
		EntriesCopy:Add(Name, -Entry)
	end
	return Map2(self.Types, nil, EntriesCopy)
end;

Map2.Merge = function(self, From)
	for Index = 1, From.Entries:NumKeys() do
		local Name, Entry = From.Entries:GetPair(Index)
		if self.Entries.Present[Name] then
			self.Entries:Get(Name):Merge(Entry)
			--self.Entries:Set(Name, self.Entries:Get(Name) + Entry)
		else
			self.Entries:Add(Name, Entry)
		end
	end
	--[[for Name in pairs(From.Entries) do
		if Into.Entries[Name] then
			Into.Entries[Name] = Into.Entries[Name] + From.Entries[Name]
		else
			Into.Entries[Name] = From.Entries[Name]
		end
	end]]
end;

return Map2
