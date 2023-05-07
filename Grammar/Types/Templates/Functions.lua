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

return Template.Namespace{
	Join = Template.Definition(
		CanonicalName("Data", CanonicalName"String"),
		Aliasable.Type.Definition(
			Syntax.Tokens{
				PEG.Optional(PEG.Pattern"Join"), 
				Construct.AliasableType"Data.Array<Data.String>"
			},
			function(Arguments)
				return table.concat(Arguments)
			end
		)
	);

	Equals = Template.Definition(
		CanonicalName("Data", CanonicalName"Boolean"),
		Incomplete(
			PEG.Pattern"Equals",
			function(Canonical)--Equals<TypeSpecifier>
				Canonical = InvertName(Canonical)
				return PEG.Apply(
					Construct.ArgumentList{Variable.Canonical"Types.Basic.Template.TypeSpecifier"},
					function(Specifier) -- Generate the match Specifier and the Added Types
						local GeneratedTypes = Aliasable.Namespace()

						if Specifier.GeneratedTypes then
							GeneratedTypes = GeneratedTypes + Specifier.GeneratedTypes
						end
						
						
						local InstanceName = CanonicalName(Canonical.Name .."<".. InvertName(Specifier.Target)() ..">", Canonical.Namespace)
						local Namespace = CreateNamespaceFor(
							Aliasable.Type.Definition(
								Construct.ArgumentList{
									Construct.AliasableType(Specifier.Target(true)),
									Construct.AliasableType(Specifier.Target(true))
								},
								function(LHS, RHS)
									return LHS == RHS
								end
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
		)
	);
}
