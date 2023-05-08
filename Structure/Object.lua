local Tools = require"Moonrise.Tools"
local OOP = require"Moonrise.OOP"

local type = Tools.Inspect.GetType

---@class Sisyphus2.Structure.Object
local Object = OOP.Declarator.Shortcuts"Sisyphus2.Structure.Object"

function Object:Decompose(...) print(self) error"Not Implemented" end
function Object:Copy() error"Not Implemented" end

---@param From Sisyphus2.Structure.Object
function Object:Merge(From) error"Not Implemented" end

function Object:__call(...) --Decompose
	--local Decomposed = self:Decompose(...)

	--[[if getmetatable(Decomposed) then --why was this here?
		getmetatable(Decomposed).__source = self; --TODO preserve during copy
	end]]
	error"Don't use"
	local Decomposed = self:Decompose(...)
	return Decomposed
end;

function Object:__unm() --Copy
	Tools.Debug.PrintCaller()
	error"Dont use"
	--local New = self:Copy()
	--assert(OOP.Reflection.Type.Of(getmetatable(self), New))
	local New = self:Copy()
	return New
end;

function Object:__add(Additions) --Merge
	--Tools.Debug.PrintCaller()
	if type(Additions) ~= "table" then
		Additions = {Additions}
	end

	local Into = self:Copy()
	local Count = #Additions
	for Index = 1, Count do
		local Addition = Additions[Index]	
		Into:Merge(Addition)
	end

	return Into
end;

local Cache = {}
local QueryCache = {}
function Object:__mod(TypeQuery) --Typename lookup
	local Typename = OOP.Reflection.Type.Name(self)
	local TypeParts = Cache[Typename]
	if not Cache[Typename] then
		TypeParts = {}
		local Exploded = Tools.String.Explode(Typename,".")
		for Index = 1, #Exploded do
			local SubType = Exploded[Index]
			TypeParts[SubType] = Index
			TypeParts[Index] = SubType
		end
		Cache[Typename] = TypeParts
	end
	local QueryParts = QueryCache[TypeQuery]
	if not QueryParts then
		QueryParts = Tools.String.Explode(TypeQuery, ".")
		QueryCache[TypeQuery] = QueryParts
	end
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

function Object:__div(Type) -- /"Type" Iteratively decomposes until it's of Type
	local Decomposed = self
	while not OOP.Reflection.Type.Name(Decomposed):match(Type .."$") do
		Decomposed = Decomposed:Decompose()
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

return Object
