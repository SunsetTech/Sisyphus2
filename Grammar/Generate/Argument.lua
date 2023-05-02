local Import = require"Toolbox.Import"

local Compiler = require"Sisyphus2.Compiler"
local Nested = Compiler.Objects.Nested
local PEG = Nested.PEG
local Aliasable = Compiler.Objects.Aliasable
local Template = Compiler.Objects.Template

local Parse = Import.Module.Relative"Objects.Parse"

local Argument = {}

function Argument.Patterns(Parameters)
	local Patterns = {}
	
	for Index, Parameter in pairs(Parameters) do
		Patterns[Index] = Parse.Aliasable(Parameter.Specifier.Target())
	end
	
	return Parse.List(Patterns)
end

function Argument.Resolver(Location)
	return function()
		return Compiler.Transform.Resolvable(
			function(Environment)
				return Environment.Variables[Location]
			end
		)
	end
end

function Argument.Types(Parameters)
	local Variables = Template.Namespace()
	local GeneratedTypes = Aliasable.Namespace()
	--print("PRocessing", #Parameters, "Parameters")
	for Index, Parameter in pairs(Parameters) do
		if Parameter.Specifier.GeneratedTypes then
			GeneratedTypes = GeneratedTypes + Parameter.Specifier.GeneratedTypes
		end
		--print("Creating", Parameter.Specifier.Target(), "Variable")
		Variables.Children.Entries[Parameter.Name] = Template.Definition(
			Parameter.Specifier.Target,
			Aliasable.Type.Definition(
				PEG.Pattern(Parameter.Name),
				Argument.Resolver(Parameter.Name)
			)
		);
	end
	
	return Variables, GeneratedTypes
end

return Argument
