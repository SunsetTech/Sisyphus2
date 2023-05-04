local Tools = require"Moonrise.Tools"
local type = Tools.Inspect.GetType

local OrderedMap = require"Moonrise.Object.OrderedMap"

local OOP = require"Moonrise.OOP"

---@class Sisyphus2.Compiler.Objects.Map:Sisyphus2.Compiler.Object
---@operator call:Sisyphus2.Compiler.Objects.Map
---@field Types string[]
---@field Entries table<string, Sisyphus2.Compiler.Object>
local Map = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Map", {
		require"Sisyphus2.Compiler.Object"
	}
)

Map.Initialize = function(_, self, Types, Entries, _Entries)
	--print_caller_info()
	self.Types =
		type(Types) == "string"
		and {Types}
		or Types
	--self.Entries = setmetatable(Entries, {__newindex=function(_,k,v) print(k,v) print_caller_info() rawset(Entries, k, v) end;})
	self.Entries = Entries or {}
end;

Map.Add = function(self, Key, Value)
	self.Entries[Key] = Value
end;

Map.Decompose = function(self)
	local Decomposed = {}

	for Key, Entry in pairs(self.Entries) do
		local TypeCheck = false
		for _, Type in pairs(self.Types) do
			if Entry%Type then
				TypeCheck = true
				break
			end
		end
		assert(TypeCheck)
		Decomposed[Key] = Entry()
	end

	return Decomposed
end;

Map.Copy = function(self)
	local EntriesCopy = {}
	for Name, Entry in pairs(self.Entries) do
		EntriesCopy[Name] = -Entry
	end
	return Map(self.Types, EntriesCopy)
end;

Map.Merge = function(Into, From)
	for Name in pairs(From.Entries) do
		if Into.Entries[Name] then
			Into.Entries[Name] = Into.Entries[Name] + From.Entries[Name]
		else
			Into.Entries[Name] = From.Entries[Name]
		end
	end
end;

return Map
