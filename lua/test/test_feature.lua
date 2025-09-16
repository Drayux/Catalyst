--- TEST GLOBALS ---
TEST_OUTPUT = false
---

local test_result = true
local features = require("lua.feature")

-- Should give us a feature module that will only try to install one feature
features("zsh")
features.print()



return test_result
