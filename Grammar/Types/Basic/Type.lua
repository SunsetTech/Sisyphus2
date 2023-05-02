local Import = require"Toolbox.Import"
local Tools = require"Toolbox.Tools"

local Compiler = require"Sisyphus2.Compiler"
local Lookup = Compiler.Lookup
local Basic = Compiler.Objects.Basic
local Nested = Compiler.Objects.Nested
local PEG = Nested.PEG
local Variable = PEG.Variable

local Objects = Import.Module.Relative"Objects"
local Syntax = Objects.Syntax
local Parse = Objects.Parse
local Static = Objects.Static

local Generate = Import.Module.Relative"Generate"

local Vlpeg = require"Sisyphus2.Vlpeg"

return Basic.Namespace{
	Name = Basic.Namespace{
		Part = Basic.Type.Definition(
			PEG.Capture(PEG.Atleast(1, Static.Alpha))
		);
		
		Full = Basic.Type.Definition(
			Parse.Multiple(Parse.Basic"Type.Name.Part", PEG.Pattern".", PEG.Sequence)
		);
		
		Canonical = Basic.Type.Definition(
			PEG.Apply(
				Parse.Basic"Type.Name.Full",
				function(...)
					local Canonical
					for _, Part in pairs{...} do
						Canonical = Compiler.Objects.CanonicalName(Part, Canonical)
					end
					--print("GENERATED", Canonical())
					return Canonical
				end
			)
		);
	};
	
	Specifier = Basic.Type.Definition(
		PEG.Apply(
			Parse.ChangeGrammar(
				PEG.Apply( 
					PEG.Sequence{Parse.Basic"Type.Name.Canonical", Static.GetEnvironment},
					Generate.Type.Completer
				)
			),
			Tools.Functional.Packer{"Target", "GeneratedTypes"}
		)
	);
}
