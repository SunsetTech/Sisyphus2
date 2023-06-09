local Import = require"Toolbox.Import"
local Execution = require "Sisyphus2.Interpreter.Execution"

local Structure = require"Sisyphus2.Structure"
local CanonicalName = Structure.CanonicalName
local Nested = Structure.Nested
local PEG = Nested.PEG
local Basic = Structure.Basic
local Aliasable = Structure.Aliasable

local Construct = Import.Module.Relative"Objects.Construct"
local Static = require"Sisyphus2.Interpreter.Parse.Static"
local Dynamic = require"Sisyphus2.Interpreter.Parse.Dynamic"
local Syntax = Import.Module.Relative"Objects.Syntax"

local OOP = require"Moonrise.OOP"

local Incomplete = OOP.Declarator.Shortcuts(
	"Sisyphus2.Grammar.Objects.Aliasable.Type.Definition.Incomplete", {
		require"Sisyphus2.Structure.Object"
	}
)

local function Generate(Specifier, GeneratedTypes, Environment)
	local CurrentGrammar = Environment.Grammar
	local New = Aliasable.Grammar(
		Construct.AliasableType(Specifier:Decompose()),
		CurrentGrammar.AliasableTypes + GeneratedTypes,
		CurrentGrammar.BasicTypes,
		CurrentGrammar.Syntax,
		CurrentGrammar.Information
	)
	return New
end

local function Passthrough(...)
	local Args = {...}
	local Returns = {}
	for k,v in pairs(Args) do
		Returns[k] = Execution.ResolveArgument(v)
	end
	return table.unpack(Returns)
end

local Decompose = function(self)
	local Decomposed = Aliasable.Type.Definition(
		Dynamic.Grammar(
			PEG.Apply(
				PEG.Sequence{
					Syntax.Tokens{
						self.Pattern,
						self.Complete(self.Canonical)
					},
					Static.GetEnvironment
				},
				Generate
			)
		),
		Execution.NamedFunction("Incomplete.Passthrough",Passthrough),
		self.Syntax,
		self.AliasableTypes,
		self.BasicTypes,
		self.Aliases
	)
	Decomposed = Decomposed:Decompose()
	return Decomposed
end;

local Copy = function(self)
	local New = Incomplete(self.Pattern:Copy(), self.Complete, self.Syntax:Copy(), self.AliasableTypes:Copy(), self.BasicTypes:Copy(), self.Canonical:Copy())
	return New
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
