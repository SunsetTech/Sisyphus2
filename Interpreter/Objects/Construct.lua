local Tools = require"Toolbox.Tools"
local Import = require"Toolbox.Import"

local Vlpeg = require"Sisyphus2.Vlpeg"
local Structure = require"Sisyphus2.Structure"
local CanonicalName = Structure.CanonicalName
local PEG = Structure.Nested.PEG
local Variable = PEG.Variable

local Syntax = Import.Module.Sister"Syntax"
local Static = require"Sisyphus2.Interpreter.Parse.Static"

local Package

local function JumpToGrammar(Subject, Position, Grammar, ...)
	local Position, Returns = Vlpeg.Match(
		Vlpeg.Apply(
			Vlpeg.Sequence(
				Tools.Error.NotMine(Vlpeg.Table,Grammar), 
				Vlpeg.Position()
			),
			function(Returns, Position)
				return Position, Returns
			end
		),
		Subject, Position, ...
	)
	return Position, table.unpack(Returns or {})
end
local function SetGrammar(NewGrammar, Environment)
	--Tools.Error.CallerAssert(NewGrammar%"Aliasable.Grammar")
	local New = NewGrammar/"userdata"
	return 
		New, {
			Grammar = NewGrammar;
			Variables = Tools.Table.Copy(Environment.Variables);
		}
end
Package = {
	DynamicParse = function(Pattern) --Matches Pattern which should produce an lpeg grammar/pattern and any number of arguments, then jumps to the returned grammar at the current position
		local New = PEG.Immediate(Pattern, JumpToGrammar)
		return New
	end;
	
	ChangeGrammar = function(Pattern) --matches Pattern which should produce an Aliasable.Grammar, then return it and a copy of the current state to DynamicParse
		local New = Package.DynamicParse(
			PEG.Apply(
				PEG.Sequence{Pattern, Static.GetEnvironment}, SetGrammar
			)
		)
		return New
	end;

	Invocation = function(Disambiguator, Pattern, Function)
		local New = PEG.Apply(
			PEG.Sequence{
				Syntax.Tokens{
					PEG.Pattern(Disambiguator),
					Pattern
				},
				Static.GetEnvironment
			},
			Function
		)
		return New
	end;

	Delimited = function(Open, Pattern, Close, Joiner)
		--Joiner = Joiner or Syntax.Tokens
		local New = (Joiner or Syntax.Tokens){Open, Pattern, Close}
		return New
	end;

	Quoted = function(Delimiter, Pattern)
		local New = Package.Delimited(Delimiter, Pattern, Delimiter)
		return New
	end;

	Centered = function(Pattern)
		local New = Package.Quoted(PEG.All(Static.Whitespace), Pattern)
		return New
	end;
	
	Array = function(Pattern, Seperator, Joiner)
		Joiner = Joiner or Syntax.Tokens
		local New = Joiner{Pattern, PEG.All(Joiner{Seperator, Pattern})}
		return New
	end;
	
	BasicNamespace = function(Name)
		local Name = CanonicalName(
				Name,
				CanonicalName"Types.Basic"
			)
		local New = Variable.Canonical(
			Name:Decompose()
		)
		return New
	end;

	AliasableType = function(Name)
		local New = PEG.Select{
			Variable.Canonical(
				CanonicalName(
					Name,
					CanonicalName"Types.Aliasable"
				):Decompose()
			),
			PEG.Sequence{
				PEG.Group(PEG.Constant(Name), "Basetype"),
				Package.BasicNamespace"Root.Types.Templates",
				PEG.Group(PEG.Constant(nil), "Basetype")
			}
		}
		return New
	end;

	ArgumentArray = function(ArgumentPattern)
		local New = Package.Delimited(
			PEG.Pattern"<",
			Package.Array(
				ArgumentPattern,
				Package.Centered(PEG.Optional(PEG.Pattern","))
			),
			PEG.Pattern">"
		)
		return New
	end;

	ArgumentList = function(Patterns)
		local Undelimited = Syntax.List(Patterns, Package.Centered(PEG.Optional(PEG.Pattern(","))))
		local Delimited = Package.Delimited(
			PEG.Pattern"<",
			Undelimited,
			PEG.Pattern">"
		)
		local New = PEG.Select{
			Undelimited,
			Delimited
		}
		return New
	end;
}

return Package
