local Import = require"Moonrise.Import"

local Transform = Import.Module.Relative"Transform"

local OOP = require"Moonrise.OOP"

local Completable = OOP.Declarator.Shortcuts(
	"Sisyphus2.Compiler.Objects.Aliasable.PEG.Completable", {
		require"Sisyphus2.Compiler.Objects.Nested.PEG.Base"
	}
)

local Decompose = function(self, Canonical)
	return Transform.Completable(
		self.Pattern(Canonical), 
		self.Function
	)
end; Completable.Decompose = Decompose;

local Copy = function(self)
	return Completable(-self.Pattern, self.Function)
end; Completable.Copy = Copy;

Completable.Initialize = function(_, self, Pattern, Function)
	self.Pattern = Pattern
	self.Function = Function
	self.Decompose = Decompose
	self.Copy = Copy
end;


return Completable

