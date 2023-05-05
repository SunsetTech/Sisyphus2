local Tools = require"Moonrise.Tools"

local Array = require"Sisyphus2.Compiler.Objects.Array"
local Vlpeg = require"Sisyphus2.Vlpeg"

local PEG = {
	Pattern = require"Sisyphus2.Compiler.Objects.Nested.PEG.Pattern";
}

local OOP = require"Moonrise.OOP"

local Select = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Select", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

Select.Initialize = function(_, self, Options, _Options)
	self.Options = _Options or Tools.Error.NotMine(Array,"Nested.PEG", Options)
	self.Decompose = Select.Decompose
	self.Copy = Select.Copy
end;

Select.Decompose = function(self, Canonical)
	local Patterns = self.Options(Canonical)
	return Vlpeg.Select(table.unpack(Patterns)) or PEG.Pattern(false)()
end;

Select.Copy = function(self)
	return Select(nil, (self.Options:Copy()))
end;

Select.ToString = function(self)
	local Strings = {}
	for _, Item in pairs(self.Options.Items) do
		table.insert(Strings, tostring(Item))
	end
	return "(".. table.concat(Strings, "|") ..")"
end;

return Select
