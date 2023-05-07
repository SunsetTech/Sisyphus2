local Vlpeg = require"Sisyphus2.Vlpeg"
local Array = require"Sisyphus2.Structure.Array"

local OOP = require"Moonrise.OOP"

local Sequence = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Sequence", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local Decompose = function(self, Canonical)
	--local Patterns = self.Parts(Canonical)
	return Vlpeg.Sequence(table.unpack(self.Parts(Canonical)))
end;


Sequence.Initialize = function(_, self, Parts, _Parts)
	self.Parts = _Parts or Array("Nested.PEG", Parts)
	self.Decompose = Sequence.Decompose
	self.Copy = Sequence.Copy
	self.Decompose = Decompose
end;

Sequence.Copy = function(self)
	return Sequence(nil, (self.Parts:Copy()))
end;

Sequence.ToString = function(self)
	local Strings = {}
	for _, Part in pairs(self.Parts.Items) do
		table.insert(Strings, tostring(Part))
	end
	return table.concat(Strings,"")
end;

return Sequence
