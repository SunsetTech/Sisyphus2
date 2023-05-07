local Debug = require"Moonrise.Tools.Debug"
local OrderedMap = require"Moonrise.Object.OrderedMap"
local CanonicalName = require"Sisyphus2.Structure.CanonicalName"

local OOP = require"Moonrise.OOP"

local Namer = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Namer", {
		require"Sisyphus2.Structure.Object"
	}
)

local Add = function(self, Key, Value)
	--self.Entries[Key] = Value
	self.Entries:Add(Key, Value)
end;

local Decompose = function(self, Canonical)
	local NamedEntries = {}

	--for Name, Entry in pairs(self.Entries) do
	for NameIndex = 1, self.Entries:NumKeys() do 
		local Name, Entry = self.Entries:GetPair(NameIndex)
		local TypeCheck = false
		
		--[[for TypeIndex = 1,#self.Types do
			local Type = self.Types[TypeIndex]
			if Entry%Type then
				TypeCheck = true
				break
			end
		end]]
		
		local Fullname
		if Name == 1 then
			Fullname = Canonical
		else
			Fullname = CanonicalName(Name, Canonical)
		end
		
		table.insert(
			NamedEntries,
			Entry(Fullname)
		)
	end
	
	return NamedEntries
end Namer.Decompose = Decompose;

local Copy = function(self)
	local EntriesCopy = OrderedMap()
	--for Name, Entry in pairs(self.Entries) do
	for NameIndex = 1, self.Entries:NumKeys() do
		local Name, Entry = self.Entries:GetPair(NameIndex)
		EntriesCopy:Add(Name, Entry:Copy())
		--EntriesCopy[Name] = -Entry
	end
	local Return = Namer(self.Types, nil, EntriesCopy)
	return Return
end Namer.Copy = Copy;

local Merge = function(Into, From)
	--for Name, Entry in pairs(From.Entries) do
	for NameIndex = 1, From.Entries:NumKeys() do
		local Name, Entry = From.Entries:GetPair(NameIndex)
		--Into.Entries[Name] = Entry
		Into.Entries:Add(Name, Entry)
	end
end Namer.Merge = Merge;

Namer.Initialize = function(_, self, Types, Entries, _Entries)
	--if Entries then Debug.PrintCaller(3) end
	self.Types =
		type(Types) == "string"
		and {Types}
		or Types
	if _Entries then
		self.Entries = _Entries
	else
		self.Entries = OrderedMap(Entries)
	end
	self.Add = Add
	self.Decompose = Decompose
	self.Copy = Copy
	self.Merge = Merge
	--self.Entries = setmetatable(Entries, {__newindex = function(_,k,v) print_caller_info() print("newindex",k,v) rawset(Entries, k, v) end;})
end;

return Namer

