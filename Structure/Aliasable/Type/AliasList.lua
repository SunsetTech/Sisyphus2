local Import = require"Moonrise.Import"
local Nested = Import.Module.Relative"Nested"
local PEG = Nested.PEG

local OOP = require"Moonrise.OOP"

local AliasList = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Aliasable.Type.AliasList", {
		require"Sisyphus2.Structure.Object"
	}
)

local Decompose = function(self)
	local Variables = {}
	--for Index, Name in pairs(self.Names) do
	for Index = 1, #self.Names do local Name = self.Names[Index]
		Variables[Index] = PEG.Sequence{PEG.Pattern":", PEG.Variable.Canonical(Name)}
	end
	local New = PEG.Select(Variables)
	return New
end;

local Copy = function(self)
	local Names = {}
	for Index = 1, #self.Names do local Name = self.Names[Index]
		Names[Index] = Name
	end
	local New = AliasList(Names)
	return New
	--return Tools.Table.Copy(self.Names)
end;


AliasList.Initialize = function(_, self, Names)
	self.Names = Names or {}
	self.Decompose = Decompose
	self.Copy = Copy
	--[[for Index, _ in pairs(self.Names) do
		Tools.Error.CallerAssert(type(Index) == "number", "hmm")
	end]]
end;
return AliasList
