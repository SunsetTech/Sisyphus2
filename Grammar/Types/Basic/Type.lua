local Import = require"Toolbox.Import"
local Tools = require"Toolbox.Tools"

local Structure = require"Sisyphus2.Structure"
local Basic = Structure.Basic
local Nested = Structure.Nested
local PEG = Nested.PEG

local Objects = Import.Module.Relative"Objects"
local Parse = Objects.Parse
local Static = Objects.Static

local Generate = require"Sisyphus2.Interpreter.Generate"


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
					local Parts = {...}
					local Canonical
					--for _, Part in pairs{...} do
					for Index = 1, #Parts do
						local Part = Parts[Index]
						Canonical = Structure.CanonicalName(Part, Canonical)
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
