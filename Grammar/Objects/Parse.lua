local Tools = require"Toolbox.Tools"
local Import = require"Toolbox.Import"

local Vlpeg = require"Sisyphus.Vlpeg"
local Compiler = require"Sisyphus.Compiler"
local CanonicalName = Compiler.Objects.CanonicalName
local PEG = Compiler.Objects.Nested.PEG
local Variable = PEG.Variable

local Syntax = Import.Module.Sister"Syntax"
local Static = Import.Module.Sister"Static"

local Parse

Parse = {
	Error = function(Message)
		return PEG.Immediate(
			Pattern,
			function(Subject, Position)
				error(
					Tools.String.Format"%s\n\tat %s"(Message, Subject:sub(Position,Position + 20))
				)
			end
		)
	end;
	
	Expect = function(Pattern)
		return PEG.Select{
			Pattern,
			Parse.Error("Expected ".. tostring(Pattern))
		}
	end;

	Dynamic = function(Pattern)
		return PEG.Immediate(
			Pattern,
			function(Subject, Position, Grammar, ...)
				Tools.Error.CallerAssert(type(Grammar) == "userdata", "Expected a userdata(lpeg pattern)")
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
		--local CallerInfo = debug.getinfo(2)
		return Parse.Dynamic(
			PEG.Apply(
				PEG.Sequence{Pattern, Static.GetEnvironment}, 
				function(NewGrammar, Environment)
					if Tools.Type.GetType(NewGrammar) == "table" then
						--print(CallerInfo.name, CallerInfo.source, CallerInfo.currentline)
					end
					Tools.Error.CallerAssert(NewGrammar%"Aliasable.Grammar")
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
		return Parse.Delimited(Delimiter, Pattern, Delimiter)
	end;

	Centered = function(Pattern)
		return Parse.Quoted(PEG.All(Static.Whitespace), Pattern)
	end;
	
	Multiple = function(Pattern, Seperator, Joiner)
		Joiner = Joiner or Syntax.Tokens
		return Joiner{Pattern, PEG.All(Joiner{Seperator, Pattern})}
	end;
	
	Basic = function(Name)
		return Variable.Canonical(
			CanonicalName(
				Name,
				CanonicalName"Types.Basic"
			)()
		)
	end;

	Aliasable = function(Name)
		assert(Name)
		return PEG.Debug(PEG.Sequence{
			PEG.Group(PEG.Constant(Name), "Basetype"),
			PEG.Select{
				Variable.Canonical(
					CanonicalName(
						Name,
						CanonicalName"Types.Aliasable"
					)()
				),
				PEG.Sequence{
					Parse.Basic"Root.Types.Templates",
				}
			},
			PEG.Group(PEG.Constant(nil), "Basetype"),
		})
	end;

	Array = function(ArgumentPattern)
		return Parse.Delimited(
			PEG.Pattern"<",
			Parse.Multiple(
				ArgumentPattern,
				Parse.Centered(PEG.Optional(PEG.Pattern","))
			),
			PEG.Pattern">"
		)
	end;

	List = function(Patterns)
		local Undelimited = Syntax.List(Patterns, Parse.Centered(PEG.Optional(PEG.Pattern(","))))
		local Delimited = Parse.Delimited(
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

return Parse
