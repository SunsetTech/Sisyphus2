local Import = require"Toolbox.Import"

local Compiler = require"Sisyphus2.Compiler"
local Object = Compiler.Object
local CanonicalName = Compiler.Objects.CanonicalName
local Nested = Compiler.Objects.Nested
local PEG = Nested.PEG
local Variable = PEG.Variable
local Basic = Compiler.Objects.Basic
local Aliasable = Compiler.Objects.Aliasable

local Construct = Import.Module.Relative"Objects.Construct"
local Static = Import.Module.Relative"Objects.Static"
local Syntax = Import.Module.Relative"Objects.Syntax"

--a templated template
return Object( --TODO migrate to Moonrise.OOP
	"Aliasable.Type.Definition.Incomplete", { 
		Construct = function(self, Pattern, Complete, Syntax, AliasableTypes, BasicTypes, Canonical)
			self.Complete = Complete
			self.Pattern = Pattern or PEG.Pattern(true)
			self.Syntax = Syntax or Nested.Grammar()
			self.AliasableTypes = AliasableTypes or Aliasable.Namespace()
			self.BasicTypes = BasicTypes or Basic.Namespace()
			self.Canonical = Canonical or CanonicalName"__TemporaryInstance"
		end;

		Decompose = function(self)
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

		Copy = function(self)
			return -self.Pattern, self.Complete, -self.Syntax, -self.AliasableTypes, -self.BasicTypes, -self.Canonical
		end;
	}
)
