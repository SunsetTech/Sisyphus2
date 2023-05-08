local lpeg = require"lpeg"
local OOP = require"Moonrise.OOP"

local Pattern = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Nested.PEG.Pattern", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

Decompose = function(self, Canonical)
	local Decomposed = lpeg.P(self.Pattern)
	return Decomposed
end;

local Copy = function(self)
	local New = Pattern(self.Pattern)
	return New
end;

Pattern.Initialize = function(_, self, P)
	self.Pattern = P
	self.Decompose = Decompose
	self.Copy = Copy
end;

Pattern.ToString = function(self)
	if type(self.Pattern) == "userdata" then
		return"".. tostring(self.Pattern) ..""
	else
		return "".. tostring(self.Pattern):gsub("\r","\\r"):gsub("\n","\\n") ..""
	end
end;

return Pattern
