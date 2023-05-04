local Tools = require"Moonrise.Tools"
local OOP = require"Moonrise.OOP"

local type = Tools.Inspect.GetType

---@class Sisyphus2.Compiler.Object
local Object = OOP.Declarator.Shortcuts"Sisyphus2.Compiler.Object"

function Object:Decompose(...) print(self) error"Not Implemented" end
function Object:Copy() error"Not Implemented" end

---@param From Sisyphus2.Compiler.Object
function Object:Merge(From) error"Not Implemented" end

function Object:__call(...) --Decompose
	local Decomposed = self:Decompose(...)

	--[[if getmetatable(Decomposed) then --why was this here?
		getmetatable(Decomposed).__source = self; --TODO preserve during copy
	end]]
	
	return Decomposed
end;

function Object:__unm() --Copy
	local New = self:Copy()
	assert(OOP.Reflection.Type.Of(getmetatable(self), New))
	return New
end;

function Object:__add(Additions) --Merge
	
	if type(Additions) ~= "table" then
		Additions = {Additions}
	end

	local Into = -self
	for Index = 1, #Additions do
		local Addition = Additions[Index]	
		Into:Merge(Addition)
	end

	return Into
end;

function Object:__mod(TypeQuery) --Typename lookup
	local Typename = OOP.Reflection.Type.Name(self)
	local TypeParts = {}
	local Exploded = Tools.String.Explode(Typename,".")
	--for Index, SubType in pairs(Tools.String.Explode(Typename, ".")) do
	for Index = 1, #Exploded do
		local SubType = Exploded[Index]
		TypeParts[SubType] = Index
		TypeParts[Index] = SubType
	end
	
	local QueryParts = Tools.String.Explode(TypeQuery, ".")
	local RootType = QueryParts[1]
	local SubTypes = Tools.Array.Slice(QueryParts,2)
	local RootIndex = TypeParts[RootType]

	if not RootIndex then
		return false
	end
	
	for SubIndex = 1, #SubTypes do local SubType = SubTypes[SubIndex]
		if TypeParts[RootIndex + SubIndex] ~= SubType then
			return false
		end
	end
	
	return true
end;

local function GetType(Of)
	return OOP.Reflection.Type.Name(Of)
end

function Object:__div(Type) -- /"Type" Iteratively decomposes until it's of Type
	local Decomposed = self
	while not GetType(Decomposed):match(Type .."$") do
		Decomposed = Decomposed()
	end
	return Decomposed
end;

function Object:__tostring()
	--no good, it gets overriden
	if self.ToString then
		return self:ToString()
	else
		return type(self)
	end
end;

function Object:ToString()
	return type(self)
end

function Object:Initialize(Instance, Typename)
	print(Instance)
	Tools.Debug.PrintCaller(2)
	error"??????"
	print(Typename)
	assert(type(Typename) == "string")
	Instance.TypeParts = {}

	for Index, SubType in pairs(Tools.String.Explode(Typename, ".")) do
		Instance.TypeParts[SubType] = Index
		Instance.TypeParts[Index] = SubType
	end
end

return Object
--[[local function NewInstance(self, ...)
	local Data = {}
	self.__definition.Construct(Data, ...)
	local Instance = setmetatable(Data, self)
	return Instance
end]]

--[[return setmetatable(
	{
		TotalCopies = {}
	},{
		__call = function(Class, Typename, Definition)
			local TypeParts = {}

			for Index, SubType in pairs(Tools.String.Explode(Typename, ".")) do
				TypeParts[SubType] = Index
				TypeParts[Index] = SubType
			end
			
			local MT = {
				__type = "Sisyphus.Compiler.Object";
				__typename = Typename;
				__typeparts = TypeParts;
				__definition = Definition;
				__class = Class;
				__new = NewInstance;
				__call = __call;
				__unm = __unm;
				__add = __add;
				__mod = __mod;
				__div = __div;
				__tostring = __tostring;
				__index = function(t,k) if (Definition.DumpIndex) then Definition.DumpIndex(t,k) end return Definition[k] end;
			}
			return function(...)
				return MT:__new(...)
			end
		end
	}
)]]
