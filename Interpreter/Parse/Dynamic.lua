local Tools = require"Toolbox.Tools"
local Import = require"Toolbox.Import"
local Vlpeg = require"Sisyphus2.Vlpeg"
local Structure = require"Sisyphus2.Structure"
local PEG = Structure.Nested.PEG
local Static = require"Sisyphus2.Interpreter.Parse.Static"

local function Swap(Returns, CurrentPosition)
	return CurrentPosition, Returns
end

local function JumpToGrammar(Subject, StartPosition, Grammar, Environment, ...)
	local EndPosition, Returns = Vlpeg.Match(
		Vlpeg.Apply(
			Vlpeg.Sequence(Vlpeg.Table(Grammar), Vlpeg.Position()),
			Swap
		),
		Subject, StartPosition, Environment, ...
	)
	if Environment.Undo then
		Environment.Undo(Environment.Grammar)
	end
	return EndPosition, table.unpack(Returns or {})
end

local function CompileAndSetGrammar(NewGrammar, Undo)
	local New = NewGrammar/"userdata"
	return New, {Grammar = NewGrammar; Undo = Undo;}
end

local Dynamic; Dynamic = {
	Jump = function(Pattern) --Matches Pattern which should produce an lpeg grammar/pattern and any number of arguments, then jumps to the returned grammar at the current position
		local New = PEG.Immediate(Pattern, JumpToGrammar)
		return New
	end;
	
	Grammar = function(Pattern) --matches Pattern which should produce an Aliasable.Grammar, then return it and a copy of the current state to Jump
		local New = Dynamic.Jump(
			PEG.Apply(Pattern, CompileAndSetGrammar)
		)
		return New
	end;
}
return Dynamic
