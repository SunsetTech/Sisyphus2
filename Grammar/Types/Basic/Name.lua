local Import = require"Toolbox.Import"

local Structure = require"Sisyphus2.Structure"
local Basic = Structure.Basic
local Nested = Structure.Nested
local PEG = Nested.PEG
local Variable = PEG.Variable

local Construct = require"Sisyphus2.Interpreter.Objects.Construct"
local Static = require"Sisyphus2.Interpreter.Parse.Static"


return Basic.Namespace{
	Part = Basic.Type.Definition(
		PEG.Capture(PEG.Atleast(1, Static.Alpha))
	);
	
	Specifier = Basic.Type.Definition(
		Construct.Array(Variable.Canonical"Types.Basic.Name.Part", PEG.Pattern".", PEG.Sequence)
	);

	Canonical = Basic.Type.Definition(
		PEG.Apply(
			Variable.Canonical"Types.Basic.Name.Specifier",
			function(...)
				local Canonical
				local Parts = {...}
				--for _, Part in pairs{...} do
				for Index = 1, #Parts do
					local Part = Parts[Index]
					Canonical = Structure.CanonicalName(Part, Canonical)
				end
				return Canonical
			end
		)
	);

	Target = Basic.Type.Definition(
		PEG.Apply(
			Variable.Canonical"Types.Basic.Name.Specifier",
			function(...)
				local Parts = {...}
				local Root = Structure.CanonicalName(Parts[1])
				local Target = Root
				for Index = 2, #Parts do -- 1,2,3 {1,{2,{3}}}
					local Part = Parts[Index]
					Target.Namespace = Structure.CanonicalName(Parts[Index])
					Target = Target.Namespace
				end
				return Root
			end
		)
	);
}
