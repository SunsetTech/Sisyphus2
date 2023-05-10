local Import = require"Moonrise.Import"

local Execution = require"Sisyphus2.Interpreter.Execution"

local OOP = require"Moonrise.OOP"

local Completable = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Aliasable.PEG.Completable", {
		require"Sisyphus2.Structure.Nested.PEG.Base"
	}
)

local Decompose = function(self, Canonical)
	local Decomposed = Execution.Completable(
		self.Pattern:Decompose(Canonical), 
		self.Function
	)
	return Decomposed
end; Completable.Decompose = Decompose;

local Copy = function(self)
	local New = Completable(self.Pattern:Copy(), self.Function)
	return New
end; Completable.Copy = Copy;

Completable.Initialize = function(_, self, Pattern, Function)

	self.Pattern = Pattern
	self.Function = Function
	self.Decompose = Decompose
	self.Copy = Copy
end;


return Completable

