local Tools = require"Toolbox.Tools"
local Import = require"Toolbox.Import"
local Vlpeg = require"Sisyphus2.Vlpeg"
local Structure = require"Sisyphus2.Structure"
local PEG = Structure.Nested.PEG
local Static = require"Sisyphus2.Interpreter.Parse.Static"

local Count = 0
local function JumpToGrammar(Subject, StartPosition, Grammar, ...)
	local EndPosition, Returns = Vlpeg.Match(
		Vlpeg.Apply(
			Vlpeg.Sequence(
				Tools.Error.NotMine(Vlpeg.Table,Grammar), 
				Vlpeg.Position()
			),
			function(Returns, CurrentPosition)
				return CurrentPosition, Returns
			end
		),
		Subject, StartPosition, ...
	)
	return EndPosition, table.unpack(Returns or {})
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
local Dynamic
Dynamic = {
	Jump = function(Pattern) --Matches Pattern which should produce an lpeg grammar/pattern and any number of arguments, then jumps to the returned grammar at the current position
		local New = PEG.Immediate(Pattern, JumpToGrammar)
		return New
	end;
	
	Grammar = function(Pattern) --matches Pattern which should produce an Aliasable.Grammar, then return it and a copy of the current state to Jump
		local New = Dynamic.Jump(
			PEG.Apply(
				PEG.Sequence{Pattern, Static.GetEnvironment}, SetGrammar
			)
		)
		return New
	end;
}
return Dynamic
