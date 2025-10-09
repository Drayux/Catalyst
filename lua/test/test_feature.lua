--- TEST GLOBALS ---
TEST_OUTPUT = true
---

local test_result = true
local features = require("lua.feature")

-- Should give us a feature module that will only try to install one feature
features("zsh")
features.print()

local spec_name, spec_obj
for _name, _obj in pairs(features) do
	spec_name = _name
	spec_obj = _obj
	break
end

print("Installing:", spec_name, spec_obj)
spec_obj:Process()

return test_result
