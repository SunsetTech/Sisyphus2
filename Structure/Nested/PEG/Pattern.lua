local lpeg = require"lpeg"
local OOP = require"Moonrise.OOP"

local Pattern = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Pattern", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

Decompose = function(self, Canonical)
	return lpeg.P(self.Pattern)
end;

Pattern.Initialize = function(_, self, P)
	self.Pattern = P
	self.Decompose = Decompose
end;


Pattern.Copy = function(self)
	return Pattern(self.Pattern)
end;

Pattern.ToString = function(self)
	if type(self.Pattern) == "userdata" then
		return"".. tostring(self.Pattern) ..""
	else
		return "".. tostring(self.Pattern):gsub("\r","\\r"):gsub("\n","\\n") ..""
	end
end;

return Pattern
