local Module = require"Moonrise.Import.Module"

local Tests = {
	"Flat";
	"Nested";
	"Basic";
	"Aliasable";
	"Template";
}

for Index, Name in pairs(Tests) do
	Tests[Index] = {Name, Module.Child("Test_".. Name)}
end

return function()
	for _, Test in pairs(Tests) do
		print("Running Test ".. Test[1])
		Test[2]()
		print"Passed"
	end
end
