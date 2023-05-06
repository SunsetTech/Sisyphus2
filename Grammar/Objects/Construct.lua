local Tools = require"Toolbox.Tools"
local Import = require"Toolbox.Import"

local Vlpeg = require"Sisyphus2.Vlpeg"
local Compiler = require"Sisyphus2.Compiler"
local CanonicalName = Compiler.Objects.CanonicalName
local PEG = Compiler.Objects.Nested.PEG
local Variable = PEG.Variable

local Syntax = Import.Module.Sister"Syntax"
local Static = Import.Module.Sister"Static"

local Package

local function JumpToGrammar(Subject, Position, Grammar, ...)
	return Vlpeg.Match(
		Vlpeg.Apply(
			Vlpeg.Sequence(
				Tools.Error.NotMine(Vlpeg.Table,Grammar), 
				Vlpeg.Position()
			),
			function(Returns, Position)
				return Position, table.unpack(Returns)
			end
		),
		Subject, Position, ...
	)
end
local function SetGrammar(NewGrammar, Environment)
	--Tools.Error.CallerAssert(NewGrammar%"Aliasable.Grammar")
	return 
		NewGrammar/"userdata", {
			Grammar = NewGrammar;
			Variables = Tools.Table.Copy(Environment.Variables);
		}
end
Package = {
	DynamicParse = function(Pattern) --Matches Pattern which should produce an lpeg grammar/pattern and any number of arguments, then jumps to the returned grammar at the current position
		return PEG.Immediate(Pattern, JumpToGrammar)
	end;
	
	ChangeGrammar = function(Pattern) --matches Pattern which should produce an Aliasable.Grammar, then return it and a copy of the current state to DynamicParse
		return Package.DynamicParse(
			PEG.Apply(
				PEG.Sequence{Pattern, Static.GetEnvironment}, SetGrammar
			)
		)
	end;

	Invocation = function(Disambiguator, Pattern, Function)
		return PEG.Apply(
			PEG.Sequence{
				Syntax.Tokens{
					PEG.Pattern(Disambiguator),
					Pattern
				},
				Static.GetEnvironment
			},
			Function
		)
	end;

	Delimited = function(Open, Pattern, Close, Joiner)
		--Joiner = Joiner or Syntax.Tokens
		return (Joiner or Syntax.Tokens){Open, Pattern, Close}
	end;

	Quoted = function(Delimiter, Pattern)
		return Package.Delimited(Delimiter, Pattern, Delimiter)
	end;

	Centered = function(Pattern)
		return Package.Quoted(PEG.All(Static.Whitespace), Pattern)
	end;
	
	Array = function(Pattern, Seperator, Joiner)
		Joiner = Joiner or Syntax.Tokens
		return Joiner{Pattern, PEG.All(Joiner{Seperator, Pattern})}
	end;
	
	BasicNamespace = function(Name)
		return Variable.Canonical(
			CanonicalName(
				Name,
				CanonicalName"Types.Basic"
			)()
		)
	end;

	AliasableType = function(Name)
		return PEG.Select{
			Variable.Canonical(
				CanonicalName(
					Name,
					CanonicalName"Types.Aliasable"
				)()
			),
			PEG.Sequence{
				PEG.Group(PEG.Constant(Name), "Basetype"),
				Package.BasicNamespace"Root.Types.Templates",
				PEG.Group(PEG.Constant(nil), "Basetype")
			}
		}
	end;

	ArgumentArray = function(ArgumentPattern)
		return Package.Delimited(
			PEG.Pattern"<",
			Package.Array(
				ArgumentPattern,
				Package.Centered(PEG.Optional(PEG.Pattern","))
			),
			PEG.Pattern">"
		)
	end;

	ArgumentList = function(Patterns)
		local Undelimited = Syntax.List(Patterns, Package.Centered(PEG.Optional(PEG.Pattern(","))))
		local Delimited = Package.Delimited(
			PEG.Pattern"<",
			Undelimited,
			PEG.Pattern">"
		)
		return PEG.Select{
			Undelimited,
			Delimited
		}
	end;
}

return Package
