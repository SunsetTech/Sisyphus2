local Import = require"Toolbox.Import"

local Structure = require"Sisyphus2.Structure"
local CanonicalName = Structure.CanonicalName
local Aliasable = Structure.Aliasable
local Template = Structure.Template
local Nested = Structure.Nested
local PEG = Nested.PEG
local Variable = PEG.Variable

local Syntax = require"Sisyphus2.Interpreter.Objects.Syntax"
local Construct = require"Sisyphus2.Interpreter.Objects.Construct"

local Incomplete = require"Sisyphus2.Interpreter.Objects.Incomplete"
local Execution = require"Sisyphus2.Interpreter.Execution"

local function CreateNamespaceFor(Entry, Canonical)
	local Namespace = Aliasable.Namespace()
	Namespace.Children.Entries:Add(Canonical.Name, Entry)
	--[[{
		[Canonical.Name] = Entry;
	}]]
	
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

local function Equal(LHS, RHS)
	return Execution.ResolveArgument(LHS) == Execution.ResolveArgument(RHS)
end
local function GenerateEqualType(Canonical, Specifier) -- Generate the match Specifier and the Added Types
	local GeneratedTypes = Aliasable.Namespace()

	if Specifier.GeneratedTypes then
		GeneratedTypes = GeneratedTypes + Specifier.GeneratedTypes
	end
	
	
	local InstanceName = CanonicalName(Canonical.Name .."<".. Specifier.Target:Decompose(true) ..">", Canonical.Namespace)
	local Namespace = CreateNamespaceFor(
		Aliasable.Type.Definition(
			Construct.ArgumentList{
				Construct.AliasableType(Specifier.Target:Decompose(true)),
				Construct.AliasableType(Specifier.Target:Decompose(true))
			},
			Execution.NamedFunction("Equal",Equal)
		),
		InstanceName
	)
	return 
		InstanceName:Invert(),
		GeneratedTypes
		+ Namespace
end
return Template.Namespace{
	Join = Template.Definition(
		CanonicalName("Data", CanonicalName"String"),
		Aliasable.Type.Definition(
			Syntax.Tokens{
				PEG.Optional(PEG.Pattern"Join"), 
				Construct.AliasableType"Data.Array<Data.String>"
			},
			Execution.NamedFunction(
				"Join", 
				function(Argument)
					Argument = Execution.ResolveArgument(Argument)
					for K,V in pairs(Argument) do
						Argument[K] = Execution.ResolveArgument(V)
					end
					return table.concat(Argument)
				end
			)
		)
	);

	Equals = Template.Definition(
		CanonicalName("Data", CanonicalName"Boolean"),
		Incomplete(
			PEG.Pattern"Equals",
			function(Canonical)--Equals<TypeSpecifier>
				Canonical = InvertName(Canonical)
				local New = PEG.Apply(
					PEG.Sequence{PEG.Constant(Canonical), Construct.ArgumentList{Variable.Canonical"Types.Basic.Template.TypeSpecifier"}},
					GenerateEqualType
				)
				return New
			end
		)
	);
}
