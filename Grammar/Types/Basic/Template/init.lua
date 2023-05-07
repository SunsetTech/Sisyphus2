local Import = require"Toolbox.Import"
local Tools = require"Toolbox.Tools"

local Structure = require"Sisyphus2.Structure"

local Basic = Structure.Objects.Basic

local PEG = require"Sisyphus2.Structure.Objects.Nested.PEG"
local Variable = PEG.Variable

local Objects = Import.Module.Relative"Objects"
local Static = Objects.Static
local Construct = Objects.Construct

local Definition = require"Sisyphus2.Grammar.Types.Basic.Template.Definition"
local TypeSpecifier = require"Sisyphus2.Grammar.Types.Basic.Template.TypeSpecifier"

return Basic.Namespace{
	TypeSpecifier = Basic.Type.Definition(
		PEG.Apply(
			Construct.ChangeGrammar(
				PEG.Apply(
					PEG.Sequence{
						Variable.Canonical"Types.Basic.Name.Target",
						Static.GetEnvironment
					},
					TypeSpecifier.GetCompleter
				)
			),
			function(Target, GeneratedTypes)
				return {
					Target = Target;
					GeneratedTypes = GeneratedTypes;
				}
			end
		)
	);

	Parameter = Basic.Type.Definition(
		PEG.Table(
			Construct.ArgumentList{
				PEG.Group(
					Variable.Canonical"Types.Basic.Template.TypeSpecifier", "Specifier"
				),
				PEG.Group(
					Variable.Canonical"Types.Basic.Name.Part", "Name"
				)
			}
		)
	);

	Parameters = Basic.Type.Definition(
		PEG.Table(
			Construct.ArgumentArray(
				Variable.Canonical"Types.Basic.Template.Parameter"
			)
		)
	);

	Declaration = Basic.Type.Definition(
		Construct.ChangeGrammar(
			Construct.Invocation(
				"Template",
				Construct.ArgumentList{
					Variable.Canonical"Types.Basic.Name.Canonical",
					Variable.Canonical"Types.Basic.Template.Parameters",
					Variable.Canonical"Types.Basic.Name.Target"
				},
				Definition.Generate
			)
		)
	);
}
