local Tools = require"Moonrise.Tools"

local Array = require"Sisyphus2.Structure.Array"
local Vlpeg = require"Sisyphus2.Vlpeg"

local PEG = {
	Pattern = require"Sisyphus2.Structure.Nested.PEG.Pattern";
}

local OOP = require"Moonrise.OOP"

local Select = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Select", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

Select.Initialize = function(_, self, Options, _Options)
	self.Options = _Options or Tools.Error.NotMine(Array,"Nested.PEG", Options)
	self.Decompose = Select.Decompose
	self.Copy = Select.Copy
end;

Select.Decompose = function(self, Canonical)
	local Patterns = self.Options:Decompose(Canonical)
	local Decomposed = Vlpeg.Select(table.unpack(Patterns)) or Vlpeg.Pattern(false)
	return Decomposed
end;

Select.Copy = function(self)
	local New = Select(nil, self.Options:Copy())
	return New
end;

Select.ToString = function(self)
	local Strings = {}
	for _, Item in pairs(self.Options.Items) do
		table.insert(Strings, tostring(Item))
	end
	return "(".. table.concat(Strings, "|") ..")"
end;

return Select
