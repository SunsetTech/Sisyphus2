local lpeg = require"lpeg"
local OOP = require"Moonrise.OOP"

local Pattern = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Nested.PEG.Pattern", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

Pattern.Initialize = function(_, self, P)
	self.Pattern = P
end;

Pattern.Decompose = function(self, Canonical)
	return lpeg.P(self.Pattern)
end;

Pattern.Copy = function(self)
	return Pattern(self.Pattern)
end;

Pattern.ToString = function(self)
	if type(self.Pattern) == "userdata" then
		return"\27[34m".. tostring(self.Pattern) .."\27[0m"
	else
		return "\27[30m\27[4m".. tostring(self.Pattern):gsub("\r","\\r"):gsub("\n","\\n") .."\27[0m"
	end
end;

return Pattern
