local Tools = require"Toolbox.Tools"
local PEG = require"Sisyphus2.Compiler.Objects.Nested.PEG"

local TypeSpecifier = {}

---@param Namespace Sisyphus2.Compiler.Objects.Aliasable.Namespace
---@param Specifier Sisyphus2.Compiler.Objects.CanonicalName
---@return Sisyphus2.Compiler.Objects.Aliasable.Namespace
TypeSpecifier.Lookup = function(Namespace, Specifier)
	local Result = Namespace.Children.Entries[Specifier.Name]
	---@cast Result Sisyphus2.Compiler.Objects.Aliasable.Namespace
	assert(Result ~= nil, "Couldn't find ".. Specifier())
	if Specifier.Namespace then assert(Result%"Aliasable.Namespace") end
	return 
		Specifier.Namespace
		and TypeSpecifier.Lookup(Result, Specifier.Namespace)
		or Result
end

function TypeSpecifier.GetCompleter(Specifier, Environment)
	local TypeDefinition = TypeSpecifier.Lookup(Environment.Grammar.AliasableTypes, Specifier)
	Tools.Error.CallerAssert(TypeDefinition%"Aliasable.Type.Definition" or TypeDefinition%"Aliasable.Type.Incomplete")
	
	local CurrentGrammar = Environment.Grammar
	local ResumePattern = CurrentGrammar.InitialPattern
	
	if TypeDefinition%"Aliasable.Type.Definition.Incomplete" then
		CurrentGrammar.InitialPattern = PEG.Apply(
			PEG.Debug(TypeDefinition.Complete(Specifier)),
			function(...)
				CurrentGrammar.InitialPattern = ResumePattern
				return ...
			end
		)
	elseif TypeDefinition%"Aliasable.Type.Definition" then
		CurrentGrammar.InitialPattern = PEG.Debug(
			PEG.Apply(
				PEG.Pattern(0),
				function()
					CurrentGrammar.InitialPattern = ResumePattern
					return Specifier
				end
			)
		)
	end
	return CurrentGrammar
end

return TypeSpecifier
