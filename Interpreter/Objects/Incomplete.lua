local Import = require"Toolbox.Import"

local Structure = require"Sisyphus2.Structure"
local Object = Structure.Object
local CanonicalName = Structure.CanonicalName
local Nested = Structure.Nested
local PEG = Nested.PEG
local Variable = PEG.Variable
local Basic = Structure.Basic
local Aliasable = Structure.Aliasable

local Construct = Import.Module.Relative"Objects.Construct"
local Static = Import.Module.Relative"Objects.Static"
local Syntax = Import.Module.Relative"Objects.Syntax"

local OOP = require"Moonrise.OOP"

local Incomplete = OOP.Declarator.Shortcuts(
	"Sisyphus2.Grammar.Objects.Aliasable.Type.Definition.Incomplete", {
		require"Sisyphus2.Structure.Object"
	}
)

local Decompose = function(self)
	return Aliasable.Type.Definition(
		Construct.ChangeGrammar(
			PEG.Apply(
				PEG.Sequence{
					Syntax.Tokens{
						self.Pattern,
						self.Complete(self.Canonical)
					},
					Static.GetEnvironment
				},
				function(Specifier, GeneratedTypes, Environment)
					local CurrentGrammar = Environment.Grammar
					return Aliasable.Grammar(
						Construct.AliasableType(Specifier()),
						CurrentGrammar.AliasableTypes + GeneratedTypes,
						CurrentGrammar.BasicTypes,
						CurrentGrammar.Syntax,
						CurrentGrammar.Information
					)
				end
			)
		),
		function(...)
			return ...
		end,
		self.Syntax,
		self.AliasableTypes,
		self.BasicTypes,
		self.Aliases
	)()
end;

local Copy = function(self)
	return Incomplete(self.Pattern:Copy(), self.Complete, self.Syntax:Copy(), self.AliasableTypes:Copy(), self.BasicTypes:Copy(), self.Canonical:Copy())
end;

Incomplete.Initialize = function(_, self, Pattern, Complete, Syntax, AliasableTypes, BasicTypes, Canonical)
	self.Complete = Complete
	self.Pattern = Pattern or PEG.Pattern(true)
	self.Syntax = Syntax or Nested.Grammar()
	self.AliasableTypes = AliasableTypes or Aliasable.Namespace()
	self.BasicTypes = BasicTypes or Basic.Namespace()
	self.Canonical = Canonical or CanonicalName"__TemporaryInstance"
	self.Decompose = Decompose
	self.Copy = Copy
end;

return Incomplete