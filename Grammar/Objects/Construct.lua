local Tools = require"Toolbox.Tools"
local Import = require"Toolbox.Import"

local Vlpeg = require"Sisyphus.Vlpeg"
local Compiler = require"Sisyphus.Compiler"
local CanonicalName = Compiler.Objects.CanonicalName
local PEG = Compiler.Objects.Nested.PEG
local Variable = PEG.Variable

local Syntax = Import.Module.Sister"Syntax"
local Static = Import.Module.Sister"Static"

local Package

Package = {
	DynamicParse = function(Pattern)
		return PEG.Immediate(
			Pattern,
			function(Subject, Position, Grammar, ...)
				--Tools.Error.CallerAssert(type(Grammar) == "userdata", "Expected a userdata(lpeg pattern)")
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
		)
	end;
	
	ChangeGrammar = function(Pattern)
		return Package.DynamicParse(
			PEG.Apply(
				PEG.Sequence{Pattern, Static.GetEnvironment}, 
				function(NewGrammar, Environment)
					--Tools.Error.CallerAssert(NewGrammar%"Aliasable.Grammar")
					return 
						NewGrammar/"userdata", {
							Grammar = NewGrammar;
							Variables = Tools.Table.Copy(Environment.Variables);
						}
				end
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
		Joiner = Joiner or Syntax.Tokens
		return Joiner{Open, Pattern, Close}
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
