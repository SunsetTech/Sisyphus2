local Tools = require"Toolbox.Tools"
local PEG = require"Sisyphus2.Structure.Nested.PEG"

local TypeSpecifier = {}

---@param Namespace Sisyphus2.Structure.Aliasable.Namespace
---@param Specifier Sisyphus2.Structure.CanonicalName
---@return Sisyphus2.Structure.Aliasable.Namespace?
TypeSpecifier.Lookup = function(Namespace, Specifier)
	local Result = Namespace.Children.Entries:Get(Specifier.Name)
	if Result == nil then return end
	---@cast Result Sisyphus2.Structure.Aliasable.Namespace
	--assert(Result ~= nil, "Couldn't find ".. Specifier())
	if Specifier.Namespace then assert(Result%"Aliasable.Namespace") end
	return 
		Specifier.Namespace
		and TypeSpecifier.Lookup(Result, Specifier.Namespace)
		or Result
end

function TypeSpecifier.GetEnd(Specifier)
	return Specifier.Namespace and TypeSpecifier.GetEnd(Specifier.Namespace) or Specifier
end

local function RestoreInitialPatternAndReturnSpecifier(Arguments)
	Arguments.Grammar.InitialPattern=Arguments.Pattern
	return Arguments.Specifier
end

function TypeSpecifier.GetCompleter(Specifier, Environment)
	local Definition
	if Environment.Using then
		for _, Locator in pairs(Environment.Using) do
			local _Locator = Locator:Invert()
			local _Specifier = Specifier:Invert()
			TypeSpecifier.GetEnd(_Specifier).Namespace = _Locator
			Definition = TypeSpecifier.Lookup(Environment.Grammar.AliasableTypes, _Specifier:Invert())
			if Definition and (Definition%"Aliasable.Type.Definition" or Definition%"Aliasable.Type.Incomplete") then
				Specifier = _Specifier:Invert()
				break
			end
		end
		--error"?"
	end
	Definition = Definition or TypeSpecifier.Lookup(Environment.Grammar.AliasableTypes, Specifier)
	Tools.Error.CallerAssert(Definition%"Aliasable.Type.Definition" or Definition%"Aliasable.Type.Incomplete")
	local CurrentGrammar = Environment.Grammar
	local ResumePattern = CurrentGrammar.InitialPattern
	
	if Definition%"Aliasable.Type.Definition.Incomplete" then
		CurrentGrammar.InitialPattern = PEG.Apply(
			Definition.Complete(Specifier),
			function(...)
				CurrentGrammar.InitialPattern = ResumePattern
				return ...
			end
		)
	elseif Definition%"Aliasable.Type.Definition" then
		CurrentGrammar.InitialPattern = 
			PEG.Apply(
				PEG.Constant{Grammar=CurrentGrammar;Pattern=ResumePattern;Specifier=Specifier},
				RestoreInitialPatternAndReturnSpecifier
			)
		
	end
	return CurrentGrammar
end

return TypeSpecifier
