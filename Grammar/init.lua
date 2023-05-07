local Module = require"Moonrise.Import.Module"

local Vlpeg = require"Sisyphus2.Vlpeg"
local Structure = require"Sisyphus2.Structure"
local PEG = Structure.Nested.PEG
local Variable = PEG.Variable
local Template = Structure.Template
local Aliasable = Structure.Aliasable
local AliasableTypes = Module.Child"Types.Aliasable"
local Construct = require"Sisyphus2.Interpreter.Objects.Construct"

local AliasableGrammar = Aliasable.Grammar( 
	PEG.Table(
		Construct.ArgumentArray(
			Variable.Canonical"Types.Basic.Template.TypeSpecifier"
		)
	),
	Module.Child"Types.Aliasable",
	Module.Child"Types.Basic",
	nil,
	{
		Files = {};
	}
)

local TypeSpecifiers = Vlpeg.Match( --Hack to make specified completed types available
	AliasableGrammar/"userdata",
	[[<Data.Array<Data.String>>]], 1, { 
		Grammar = AliasableGrammar;
		Variables = {};
	}
) --TODO why exactly is this needed? it's for Join i think

for _, TypeSpecifier in pairs(TypeSpecifiers) do
	if TypeSpecifier.GeneratedTypes then
		AliasableGrammar.AliasableTypes = AliasableGrammar.AliasableTypes + TypeSpecifier.GeneratedTypes
	end
end

AliasableGrammar.InitialPattern = Variable.Canonical"Types.Basic.Root"

return Template.Grammar(
	AliasableGrammar,
	Module.Child"Types.Templates"
)
