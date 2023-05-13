local Execution = require "Sisyphus2.Interpreter.Execution"

local Structure = require"Sisyphus2.Structure"
local PEG = Structure.Nested.PEG
local Variable = PEG.Variable

local Construct = require"Sisyphus2.Interpreter.Objects.Construct"
local Incomplete = require"Sisyphus2.Interpreter.Objects.Incomplete"

local Box = require"Sisyphus2.Interpreter.Execution.Box"

local function CreateNamespaceFor(Entry, Canonical)
	local Namespace = Structure.Aliasable.Namespace()--[[{
		[Canonical.Name] = Entry;
	}]]
	Namespace.Children.Entries:Add(Canonical.Name, Entry)
	
	if Canonical.Namespace then
		local New = CreateNamespaceFor(
			Namespace,
			Canonical.Namespace
		)
		return New
	else
		return Namespace
	end
end

local function InvertName(Canonical)
	local Inverted = Structure.CanonicalName(Canonical.Name)
	while(Canonical.Namespace) do
		Canonical = Canonical.Namespace
		Inverted = Structure.CanonicalName(Canonical.Name, Inverted)
	end
	return Inverted
end

local function ArrayBoxer(...)
	local Arguments = {...}
	local Array = {}
	for Index = 1, #Arguments do
		Array[Index] = Execution.ResolveArgument(Arguments[Index])
	end
	return Array
end

local function PassThrough(...)
	return ...
end

local function GenerateArrayType(Canonical, Specifier) -- Generate the match Specifier and the Added Types
	local GeneratedTypes = Structure.Aliasable.Namespace()

	if Specifier.GeneratedTypes then
		GeneratedTypes = GeneratedTypes + Specifier.GeneratedTypes
	end
	
	
	local InstanceName = Structure.CanonicalName(Canonical.Name .."<".. Specifier.Target:Decompose(true) ..">", Canonical.Namespace)
	
	local Namespace = CreateNamespaceFor(
		Structure.Aliasable.Type.Definition(
			Construct.ArgumentArray(
				Construct.AliasableType(Specifier.Target:Decompose(true))
			),
			Execution.NamedFunction("Array.ArrayBoxer",Box)
		),
		InstanceName
	)
	return 
		InstanceName:Invert(),
		GeneratedTypes
		+ Namespace
end

return Structure.Aliasable.Namespace {
	Boolean = Structure.Aliasable.Type.Definition(
		PEG.Select{
			PEG.Sequence{PEG.Pattern"true", PEG.Constant(true)},
			PEG.Sequence{PEG.Pattern"false", PEG.Constant(false)}
		},
		Execution.NamedFunction("Boolean.PassThrough",PassThrough)
	);

	String = Structure.Aliasable.Type.Definition(
		Variable.Child"Syntax",
		Execution.NamedFunction("String.PassThrough",PassThrough),
		Structure.Nested.Grammar{
			Delimiter = PEG.Pattern'"';
			Open = Variable.Sibling"Delimiter";
			Close = Variable.Sibling"Delimiter";
			Contents = PEG.Capture(
				PEG.All(
					require"Sisyphus2.Structure.Nested.PEG.Dematch"(
						PEG.Pattern(1),
						Variable.Sibling"Delimiter"
					)
				)
			);
			PEG.Sequence{Variable.Child"Open", Variable.Child"Contents", Variable.Child"Close"};
		}
	);

	Array = Incomplete(
		PEG.Pattern"Array",
		function(Canonical)--Array<TypeSpecifier>
			Canonical = InvertName(Canonical)
			local New = PEG.Apply(
				PEG.Sequence{PEG.Constant(Canonical), Construct.ArgumentList{Variable.Canonical"Types.Basic.Template.TypeSpecifier"}},
				GenerateArrayType
			)
			return New
		end
	);
}
