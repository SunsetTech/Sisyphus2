local Import = require"Toolbox.Import"

local Compiler = require"Sisyphus2.Compiler"
local Basic = Compiler.Objects.Basic
local Nested = Compiler.Objects.Nested
local PEG = Nested.PEG
local Variable = PEG.Variable

local Syntax = Import.Module.Relative"Objects.Syntax"
local Construct = Import.Module.Relative"Objects.Construct"
local Static = Import.Module.Relative"Objects.Static"

local Vlpeg = require"Sisyphus2.Vlpeg"

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
				for _, Part in pairs{...} do
					Canonical = Compiler.Objects.CanonicalName(Part, Canonical)
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
				local Root = Compiler.Objects.CanonicalName(Parts[1])
				local Target = Root
				for Index = 2, #Parts do -- 1,2,3 {1,{2,{3}}}
					local Part = Parts[Index]
					Target.Namespace = Compiler.Objects.CanonicalName(Parts[Index])
					Target = Target.Namespace
				end
				return Root
			end
		)
	);
}
