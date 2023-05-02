local Vlpeg = require"Sisyphus2.Vlpeg"
local Array = require"Sisyphus2.Compiler.Objects.Array"

local OOP = require"Moonrise.OOP"

local Sequence = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Sequence", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

Sequence.Initialize = function(_, self, Parts)
	self.Parts = Array("Nested.PEG", Parts)
end;

Sequence.Decompose = function(self, Canonical)
	local Patterns = self.Parts(Canonical)
	return Vlpeg.Sequence(table.unpack(Patterns))
end;

Sequence.Copy = function(self)
	return Sequence((-self.Parts).Items)
end;

Sequence.ToString = function(self)
	local Strings = {}
	for _, Part in pairs(self.Parts.Items) do
		table.insert(Strings, tostring(Part))
	end
	return table.concat(Strings,"")
end;

return Sequence
