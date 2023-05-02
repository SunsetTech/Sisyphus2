local Import = require"Moonrise.Import"
local Nested = Import.Module.Relative"Objects.Nested"
local PEG = Nested.PEG

local OOP = require"Moonrise.OOP"

local AliasList = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Aliasable.Type.AliasList", {
		require"Sisyphus2.Compiler.Object"
	}
)

AliasList.Initialize = function(_, self, Names)
	self.Names = Names or {}
	--[[for Index, _ in pairs(self.Names) do
		Tools.Error.CallerAssert(type(Index) == "number", "hmm")
	end]]
end;

AliasList.Decompose = function(self)
	local Variables = {}
	--for Index, Name in pairs(self.Names) do
	for Index = 1, #self.Names do local Name = self.Names[Index]
		Variables[Index] = PEG.Debug(PEG.Sequence{PEG.Pattern":", PEG.Variable.Canonical(Name)})
		print(Index, Name)
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
