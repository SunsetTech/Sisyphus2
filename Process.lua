unpack = unpack or table.unpack
table.unpack = table.unpack or unpack
require"Moonrise.Import.Install".All()

local Tools = require"Moonrise.Tools"
Tools.Debug.OutputEnabled = true 
Tools.Debug.IndentChar="| "

local Vlpeg = require"Sisyphus2.Vlpeg"

local InputPath = arg[1] or error"Supply filename"
local OutputPath = arg[2] or error"Supply filename"

local InputFile = io.open(InputPath, "r") assert(InputFile)
local Input = InputFile:read"a"
InputFile:close()

collectgarbage"stop"
local TemplateGrammar = require"Sisyphus2.Grammar"
local AliasableGrammar = TemplateGrammar:Decompose()
local Grammar = AliasableGrammar/"userdata"

print"_____"
local StartTime = Tools.Profile.GetTime()
local Output = Tools.Filesystem.ChangePath(
	Tools.Path.Join(Tools.Path.DirName(InputPath)),
	Vlpeg.Match,
	Grammar, Input, 1, {
		Grammar = AliasableGrammar;

	}
)
print"_____"

print(Output)
print(collectgarbage("count")/1024 .."MB")
print((Tools.Profile.GetTime()-StartTime)*1000 .."ms")

local OutputFile = io.open(OutputPath, "w")
assert(OutputFile)
OutputFile:write(Output .."\n")
OutputFile:close()
