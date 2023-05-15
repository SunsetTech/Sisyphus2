local posix = require"posix"

local Tools = require"Moonrise.Tools"
local Import = require"Moonrise.Import"

local Vlpeg = require"Sisyphus2.Vlpeg"
local Structure = require"Sisyphus2.Structure"
local Template = Structure.Template
local Aliasable = Structure.Aliasable
local Basic = Structure.Basic
local PEG = Structure.Nested.PEG
local Variable = PEG.Variable

local Construct = require"Sisyphus2.Interpreter.Objects.Construct"
local Dynamic = require"Sisyphus2.Interpreter.Parse.Dynamic"

return Basic.Type.Set{
	Modifier = Basic.Type.Set{
		Using = Basic.Type.Definition( --broken
			Dynamic.Jump(
				Construct.Invocation(
					"Using",
					Construct.ArgumentList{Variable.Canonical"Types.Basic.Name.Target"},
					function(NamespaceLocator, Environment)
						local Using = Environment.Using or {}
						table.insert(Using, NamespaceLocator)
						local Resume = Environment.Grammar.InitialPattern
						Environment.Grammar.InitialPattern =
							PEG.Apply(
								Construct.Centered(Variable.Canonical"Types.Basic.Grammar.Modifier"),
								function(ModifiedGrammar)
									ModifiedGrammar.InitialPattern = Resume
									table.remove(Using)
									return ModifiedGrammar
								end
							)
						
						return
							Environment.Grammar/"userdata", {
								Grammar = Environment.Grammar;
								Variables = {};
								Using = Using;
							}
					end
				)
			)
		);


		--Templated parse that takes a Grammar.Modifier and uses the new grammar to match and return a.. Grammar.Modifier.
		With = Basic.Type.Definition(
			Dynamic.Jump(
				Construct.Invocation(
					"With",
					Construct.ArgumentList{Variable.Canonical"Types.Basic.Grammar.Modifier"},
					function(Grammar, Environment)
						local InitialPattern = Grammar.InitialPattern
						Grammar.InitialPattern =
							PEG.Apply(
								Construct.Centered(Variable.Canonical"Types.Basic.Grammar.Modifier"),
								function(ModifiedGrammar)
									ModifiedGrammar.InitialPattern = InitialPattern
									return ModifiedGrammar
								end
							)
						
						return
							Grammar/"userdata", {
								Grammar = Grammar;
								Variables = {};
								Using = Environment.Using
							}
					end
				)
			)
		);

		File = Basic.Type.Definition(
			Construct.Invocation(
				"File",
				Construct.ArgumentList{Construct.BasicNamespace"String"},
				function(Filename, Environment)
					local CurrentGrammar = Environment.Grammar

					local Path = posix.realpath(Filename)

					if not CurrentGrammar.Information.Files[Path] then
						local File = io.open(Path,"r")
						assert(File)
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
								Variables = Environment.Variables;
								Using = Environment.Using;
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

					--for _, Declaration in pairs(Declarations) do
					for Index = 1, #Declarations do
						local Declaration = Declarations[Index]
						--Namespace = Namespace + Declaration.Namespace
						Namespace:Merge(Declaration.Namespace)
						if Declaration.GeneratedTypes then
							--GeneratedTypes = GeneratedTypes + Declaration.GeneratedTypes
							GeneratedTypes:Merge(Declaration.GeneratedTypes)
						end
					end
					
					local CurrentGrammar = Environment.Grammar

					local New = Template.Grammar(
						Aliasable.Grammar(
							CurrentGrammar.InitialPattern,
							CurrentGrammar.AliasableTypes + GeneratedTypes,
							CurrentGrammar.BasicTypes,
							CurrentGrammar.Syntax,
							CurrentGrammar.Information
						),
						Namespace
					):Decompose()
					return New
				end
			)
		);
	}
}
