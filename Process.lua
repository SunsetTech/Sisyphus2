unpack = unpack or table.unpack
table.unpack = table.unpack or unpack
require"Moonrise.Import.Install".All()
local Tools = require"Moonrise.Tools"
local posix = require"posix"
local function getTime()
    local s,ns = posix.clock_gettime(posix.CLOCK_MONOTONIC)
    return s + ns * 1e-9
end

--[[local DebugOutput = require"Toolbox.Debug.Registry".GetDefaultPipe()
DebugOutput.IncludeSource = false
DebugOutput.Enabled = false]]

local Vlpeg = require"Sisyphus2.Vlpeg"
local Compiler = require"Sisyphus2.Compiler"

local TemplateGrammar = require"Sisyphus2.Grammar"
local AliasableGrammar = TemplateGrammar()
local Grammar = AliasableGrammar/"userdata"

local InputPath = arg[1] or error"Supply filename"
local OutputPath = arg[2] or error"Supply filename"

local InputFile = io.open(InputPath, "r")
local Input = InputFile:read"a"
InputFile:close()

print"_____"
local StartTime = getTime()
debug.sethook(nil,"clr")
local Output = Tools.Filesystem.ChangePath(
	Tools.Path.Join(Tools.Path.DirName(InputPath)),
	Vlpeg.Match,
	Grammar, Input, 1, {
		Grammar = AliasableGrammar;
		Variables = {};
	}
)
print"_____"
print(Output)
print(collectgarbage("count")/1024)
print(getTime()-StartTime .."s")
--[[for Name, Amount in pairs(Compiler.Object.TotalCopies) do
	--print(Amount .." ".. Name .." copies created")
end]]

local OutputFile = io.open(OutputPath, "w")
assert(OutputFile)
OutputFile:write(Output .."\n")
OutputFile:close()
