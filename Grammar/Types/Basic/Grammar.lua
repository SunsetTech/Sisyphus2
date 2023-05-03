local posix = require"posix"

local Tools = require"Moonrise.Tools"
local Import = require"Moonrise.Import"

local Vlpeg = require"Sisyphus2.Vlpeg"
local Compiler = require"Sisyphus2.Compiler"
local Template = Compiler.Objects.Template
local Aliasable = Compiler.Objects.Aliasable
local Basic = Compiler.Objects.Basic
local PEG = Compiler.Objects.Nested.PEG
local Variable = PEG.Variable

local Syntax = Import.Module.Relative"Objects.Syntax"
local Construct = Import.Module.Relative"Objects.Construct"

return Basic.Type.Set{
	Modifier = Basic.Type.Set{
		--Templated parse that takes a Grammar.Modifier and uses the new grammar to match and return a.. Grammar.Modifier.
		Using = Basic.Type.Definition(
			Construct.DynamicParse(
				Construct.Invocation(
					"Using",
					Construct.ArgumentList{Variable.Canonical"Types.Basic.Name.Target"},
					function(NamespaceLocator, Environment)
						print(NamespaceLocator(), Environment.Grammar)
						error"?"
						Grammar.InitialPattern =
							PEG.Apply(
								Construct.Centered(Variable.Canonical"Types.Basic.Grammar.Modifier"),
								function(ModifiedGrammar)
									ModifiedGrammar.InitialPattern = Grammar.InitialPattern
									return ModifiedGrammar
								end
							)
						
						return
							Grammar/"userdata", {
								Grammar = Grammar;
								Variables = {};
							}
					end
				)
			)
		);


		With = Basic.Type.Definition(
			Construct.DynamicParse(
				Construct.Invocation(
					"With",
					Construct.ArgumentList{Variable.Canonical"Types.Basic.Grammar.Modifier"},
					function(Grammar, Environment)
						local ResumePattern = Grammar.InitialPattern
						Grammar.InitialPattern =
							PEG.Apply(
								Construct.Centered(Variable.Canonical"Types.Basic.Grammar.Modifier"),
								function(ModifiedGrammar)
									ModifiedGrammar.InitialPattern = ResumePattern
									return ModifiedGrammar
								end
							)
						
						return
							Grammar/"userdata", {
								Grammar = Grammar;
								Variables = {};
							}
					end
				)
			)
		);

		File = Basic.Type.Definition(
			Construct.Invocation(
				"File",
				Construct.ArgumentList{Construct.AliasableType"Data.String"},
				function(Filename, Environment)
					local CurrentGrammar = Environment.Grammar

					local Path = posix.realpath(Filename)

					if not CurrentGrammar.Information.Files[Path] then
						local File = io.open(Path,"r")
						local Contents = File:read"a"
						File:close()
						
						local ResumePattern = CurrentGrammar.InitialPattern
						CurrentGrammar.InitialPattern = Variable.Canonical"Types.Basic.Grammar.Modifier"
						
						local ModifiedGrammar = Tools.Filesystem.ChangePath(
							Tools.Path.Join(Tools.Path.DirName(Path)),
							Vlpeg.Match,
							CurrentGrammar/"userdata",
							Contents, 1, {
								Grammar = CurrentGrammar;
								Variables = {};
							}
						)
						
						ModifiedGrammar.InitialPattern = ResumePattern
						ModifiedGrammar.Information.Files[Path] = true
						
						return ModifiedGrammar
					else
						return CurrentGrammar
					end
				end
			)
		);

		Templates = Basic.Type.Definition(
			Construct.Invocation(
				"Templates",
				PEG.Table(
					Construct.ArgumentArray(
						PEG.Apply(
							Variable.Canonical"Types.Basic.Template.Declaration",
							function(Namespace, GeneratedTypes)
								return {
									Namespace = Namespace;
									GeneratedTypes = GeneratedTypes;
								}
							end
						)
					)
				),
				function(Declarations, Environment)
					local Namespace = Template.Namespace()
					local GeneratedTypes = Aliasable.Namespace()

					for _, Declaration in pairs(Declarations) do
						Namespace = Namespace + Declaration.Namespace
						if Declaration.GeneratedTypes then
							GeneratedTypes = GeneratedTypes + Declaration.GeneratedTypes
						end
					end
					
					local CurrentGrammar = Environment.Grammar

					return Template.Grammar(
						Aliasable.Grammar(
							CurrentGrammar.InitialPattern,
							CurrentGrammar.AliasableTypes + GeneratedTypes,
							CurrentGrammar.BasicTypes,
							CurrentGrammar.Syntax,
							CurrentGrammar.Information
						),
						Namespace
					)()
				end
			)
		);
	}
}
