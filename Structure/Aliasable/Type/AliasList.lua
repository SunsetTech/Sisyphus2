local Import = require"Moonrise.Import"
local Nested = Import.Module.Relative"Nested"
local PEG = Nested.PEG

local OOP = require"Moonrise.OOP"

local AliasList = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Aliasable.Type.AliasList", {
		require"Sisyphus2.Structure.Object"
	}
)

AliasList.Initialize = function(_, self, Names)
	self.Names = Names or {}
	self.Decompose = AliasList.Decompose
	--[[for Index, _ in pairs(self.Names) do
		Tools.Error.CallerAssert(type(Index) == "number", "hmm")
	end]]
end;

AliasList.Decompose = function(self)
	local Variables = {}
	--for Index, Name in pairs(self.Names) do
	for Index = 1, #self.Names do local Name = self.Names[Index]
		Variables[Index] = PEG.Sequence{PEG.Pattern":", PEG.Variable.Canonical(Name)}
	end
	return PEG.Select(Variables)
end;

AliasList.Copy = function(self)
	local Names = {}
	for Index = 1, #self.Names do local Name = self.Names[Index]
		Names[Index] = Name
	end
	return AliasList(Names)
	--return Tools.Table.Copy(self.Names)
end;

return AliasList
