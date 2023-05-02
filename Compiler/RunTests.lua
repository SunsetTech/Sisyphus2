unpack = unpack or table.unpack
table.unpack = table.unpack or unpack
local Import = require"Moonrise.Import"
Import.Install.All()

require"Sisyphus2.Compiler.Tests"()
