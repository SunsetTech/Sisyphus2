local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local OrderedMap = require"Moonrise.Object.OrderedMap"

local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Structure.Map:Sisyphus2.Structure.Object
---@operator call:Sisyphus2.Structure.Map
---@field Types string[]
---@field Entries Moonrise.Object.OrderedMap
local Map = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Map", {
		require"Sisyphus2.Structure.Object"
	}
)

Map.Initialize = function(_, self, Types, Entries, _Entries)
	--print_caller_info()
	self.Types =
		type(Types) == "string"
		and {Types}
		or Types
	--self.Entries = setmetatable(Entries, {__newindex=function(_,k,v) print(k,v) print_caller_info() rawset(Entries, k, v) end;})
	self.Entries = _Entries or OrderedMap(Entries)
	self.Add = Map.Add
	self.Decompose = Map.Decompose
	self.Copy = Map.Copy
	self.Merge = Map.Merge
end;

Map.Add = function(self, Key, Value)
	self.Entries:Add(Key, Value)
end;

local GetPair = OrderedMap.GetPair
local NumKeys = OrderedMap.NumKeys

Map.Decompose = function(self)
	local Decomposed = {}

	--for Key, Entry in pairs(self.Entries) do
	for Index = 1, NumKeys(self.Entries) do
		local Key, Entry = GetPair(self.Entries, Index)
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

Map.Copy = function(self)
	local EntriesCopy = OrderedMap()
	--for Name, Entry in pairs(self.Entries) do
	for Index = 1, NumKeys(self.Entries) do
		local Name, Entry = GetPair(self.Entries,Index)
		EntriesCopy:Add(Name, Entry:Copy())
	end
	local New = Map(self.Types, nil, EntriesCopy)
	return New
end;

Map.Merge = function(self, From)
	for Index = 1, NumKeys(From.Entries) do
		local Name, Entry =GetPair(From.Entries, Index)
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

return Map
