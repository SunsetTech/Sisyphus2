local Import = require"Moonrise.Import"
local Tools = require"Moonrise.Tools"

local CanonicalName = Import.Module.Relative"CanonicalName"
local Aliasable = Import.Module.Relative"Aliasable"
local Template = {
	Namespace = Import.Module.Sister"Namespace";
}

local function LookupAliasableType(In, Canonical)
	if Canonical then
		if In%"Aliasable.Namespace" then
			return LookupAliasableType(In.Children.Entries:Get(Canonical.Name), Canonical.Namespace)
		else
			Tools.Error.CallerError(Tools.String.Format"Can't lookup %s in %s"(Canonical.Name, In))
		end
	else
		Tools.Error.CallerAssert(In and In%"Aliasable.Type.Definition", "Didnt find an aliasable type, got ".. tostring(In))
		return In
	end
end

local function RegisterTemplates(AliasableTypes, Templates, Canonical)
	--for Name, Entry in pairs(Templates.Children.Entries) do
	for Index = 1, Templates.Children.Entries:NumKeys() do
		local Name, Entry = Templates.Children.Entries:GetPair(Index)
		if Entry%"Template.Namespace" then
			RegisterTemplates(AliasableTypes, Entry, CanonicalName(Name, Canonical))
		elseif Entry%"Template.Definition" then
			local AliasableType = LookupAliasableType(AliasableTypes, Entry.Basetype)
			table.insert(AliasableType.Aliases.Names, CanonicalName(Name, Canonical)())
		end
	end
	return 
end

local OOP = require"Moonrise.OOP"

local Grammar = OOP.Declarator.Shortcuts(
	"Sisyphus2.Structure.Template.Grammar", {
		require"Sisyphus2.Structure.Object"
	}
)

Grammar.Initialize = function(_, self, AliasableGrammar, Templates)
	self.AliasableGrammar = AliasableGrammar or Aliasable.Grammar()
	self.Templates = Templates or Template.Namespace()
end;

Grammar.Decompose = function(self) --Decomposes into an Aliasable.Grammar
	local Copy = self.AliasableGrammar
	Copy = Aliasable.Grammar(
		Copy.InitialPattern,
		Copy.AliasableTypes:Copy(),
		Copy.BasicTypes,
		Copy.Syntax,
		Copy.Information
	)

	RegisterTemplates(
		Copy.AliasableTypes, 
		self.Templates,
		CanonicalName"Types.Aliasable.Templates"
	)

	Copy.AliasableTypes.Children:Add(
		"Templates",
		Aliasable.Namespace()
		+ {
			(Copy.AliasableTypes.Children.Entries:Get"Templates" or Aliasable.Namespace()),
			self.Templates()
		}
	)
	
	return Copy
end;

return Grammar
