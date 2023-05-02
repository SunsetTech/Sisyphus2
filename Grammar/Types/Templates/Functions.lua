local Import = require"Toolbox.Import"

local Compiler = require"Sisyphus2.Compiler"
local CanonicalName = Compiler.Objects.CanonicalName
local Aliasable = Compiler.Objects.Aliasable
local Template = Compiler.Objects.Template
local Nested = Compiler.Objects.Nested
local PEG = Nested.PEG
local Variable = PEG.Variable

local Syntax = Import.Module.Relative"Objects.Syntax"
local Construct = Import.Module.Relative"Objects.Construct"

local Incomplete = Import.Module.Relative"Objects.Incomplete"

local function CreateNamespaceFor(Entry, Canonical)
	local Namespace = Aliasable.Namespace{
		[Canonical.Name] = Entry;
	}
	
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
	local Inverted = Compiler.Objects.CanonicalName(Canonical.Name)
	while(Canonical.Namespace) do
		Canonical = Canonical.Namespace
		Inverted = Compiler.Objects.CanonicalName(Canonical.Name, Inverted)
	end
	return Inverted
end

return Template.Namespace{
	Join = Template.Definition(
		CanonicalName("Data", CanonicalName"String"),
		Aliasable.Type.Definition(
			PEG.Debug(Syntax.Tokens{
				PEG.Optional(PEG.Pattern"Join"), 
				Construct.AliasableType"Data.Array<Data.String>"
			}),
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
									Construct.AliasableType(InvertName(Specifier.Target)()),
									Construct.AliasableType(InvertName(Specifier.Target)())
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
