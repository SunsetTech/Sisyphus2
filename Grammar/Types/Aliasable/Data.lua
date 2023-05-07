local Import = require"Moonrise.Import"

local Structure = require"Sisyphus2.Structure"

local CanonicalName = Structure.CanonicalName
local Aliasable = Structure.Aliasable
local Nested = Structure.Nested
local PEG = Nested.PEG
local Variable = PEG.Variable

local Construct = require"Sisyphus2.Interpreter.Objects.Construct"
local Incomplete = require"Sisyphus2.Interpreter.Objects.Incomplete"
local function CreateNamespaceFor(Entry, Canonical)
	local Namespace = Aliasable.Namespace()--[[{
		[Canonical.Name] = Entry;
	}]]
	Namespace.Children.Entries:Add(Canonical.Name, Entry)
	
	if Canonical.Namespace then
		return CreateNamespaceFor(
			Namespace,
			Canonical.Namespace
		)
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

local function Box(...)
	return {...}
end

local function PassThrough(...)
	return ...
end

return Aliasable.Namespace {
	Boolean = Aliasable.Type.Definition(
		PEG.Select{
			PEG.Sequence{PEG.Pattern"true", PEG.Constant(true)},
			PEG.Sequence{PEG.Pattern"false", PEG.Constant(false)}
		},
		function(...)
			return ...
		end
	);

	String = Aliasable.Type.Definition(
		Variable.Child"Syntax",
		PassThrough,
		Nested.Grammar{
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
			return PEG.Apply(
				Construct.ArgumentList{Variable.Canonical"Types.Basic.Template.TypeSpecifier"},
				function(Specifier) -- Generate the match Specifier and the Added Types
					local GeneratedTypes = Aliasable.Namespace()

					if Specifier.GeneratedTypes then
						GeneratedTypes = GeneratedTypes + Specifier.GeneratedTypes
					end
					
					
					local InstanceName = CanonicalName(Canonical.Name .."<".. Specifier.Target(true) ..">", Canonical.Namespace)
					
					local Namespace = CreateNamespaceFor(
						Aliasable.Type.Definition(
							Construct.ArgumentArray(
								Construct.AliasableType(Specifier.Target(true))
							),
							Box
						),
						InstanceName
					)
					return 
						InvertName(InstanceName),
						GeneratedTypes
						+ Namespace
				end
			)
		end
	);
}
