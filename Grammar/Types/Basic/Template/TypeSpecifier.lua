local Tools = require"Toolbox.Tools"
local PEG = require"Sisyphus2.Compiler.Objects.Nested.PEG"

local TypeSpecifier = {}

---@param Namespace Sisyphus2.Compiler.Objects.Aliasable.Namespace
---@param Specifier Sisyphus2.Compiler.Objects.CanonicalName
---@return Sisyphus2.Compiler.Objects.Aliasable.Namespace?
TypeSpecifier.Lookup = function(Namespace, Specifier)
	local Result = Namespace.Children.Entries[Specifier.Name]
	if Result == nil then return end
	---@cast Result Sisyphus2.Compiler.Objects.Aliasable.Namespace
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

function TypeSpecifier.GetCompleter(Specifier, Environment)
	local Definition
	print(Environment.Using)
	if Environment.Using then
		for _, Locator in pairs(Environment.Using) do
			local _Locator = Locator:Invert()
			local _Specifier = Specifier:Invert()
			TypeSpecifier.GetEnd(_Specifier).Namespace = _Locator
			print("Looking up ", _Specifier())
			Definition = TypeSpecifier.Lookup(Environment.Grammar.AliasableTypes, _Specifier:Invert())
			if Definition and (Definition%"Aliasable.Type.Definition" or Definition%"Aliasable.Type.Incomplete") then
				print("Found", Definition)
				Specifier = _Specifier:Invert()
				break
			end
		end
		--error"?"
	end
	print(Specifier())
	Definition = Definition or TypeSpecifier.Lookup(Environment.Grammar.AliasableTypes, Specifier)
	assert(Definition)
	Tools.Error.CallerAssert(Definition%"Aliasable.Type.Definition" or Definition%"Aliasable.Type.Incomplete")
	print(Definition)
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
				PEG.Pattern(0),
				function()
					CurrentGrammar.InitialPattern = ResumePattern
					return Specifier
				end
			)
		
	end
	return CurrentGrammar
end

return TypeSpecifier
