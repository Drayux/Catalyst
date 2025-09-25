--- TEST GLOBALS ---
TEST_OUTPUT = true
---

local test_result = true
local path = require("lua.path")

--- BASE MODULE TEST ---

local abs_test_path = path("/absolute/test/path/")
print(abs_test_path)
assert(abs_test_path:String() == "/absolute/test/path")

local rel_test_path = path("relative/test/./path/")
print(rel_test_path)
assert(rel_test_path:String() == "relative/test/path")

---


local test_lut = {
	feature_config = "$catalyst_root/test_feature/config",
	catalyst_root = "/test/catalyst",
	install_target = "~/.config/test_feature",
	test_var = "ooga_booga",
}

local function test_NewPath(expected, ...)
	local input, lut = ...
	print(string.format("Testing path: `%s`", input))

	local test_pass = true
	-- local entry_count = 0
	local status, result = pcall(path_utils.path_Split, input, lut)
	if status then
		if not expected then
			-- Test should have reached an error
			test_pass = false

		else
			for i, v in ipairs(result) do
				print("", v)
				-- entry_count = entry_count + 1
				test_pass = test_pass and (v == expected[i])
			end

			-- if #expected ~= entry_count then
			if #expected ~= #result then
				test_pass = false
			end
		end
	else
		print(result)
		test_pass = (expected == nil) -- false if unexpected failure
	end
	print(" * " .. (test_pass and "PASS" or "FAIL"))

	if not test_pass then
		test_result = false
	end
end


-- Test path splitting

-- test_split({ "home", "Catalyst", "dotfiles" }) -- Test nil path (will probably fail on your computer)
-- test_split({ "home", "scripts", "pancakes" }, "~/scripts/pancakes") -- Test homedir lookup (will probably fail on your computer)
-- test_split(nil, "/$test_var") -- Test absolute varpath lookup with no LUT
-- test_split(nil, "$test_var") -- Test relative varpath lookup with no LUT

-- test_split({}, "/", test_lut) -- Test root
-- test_split({ "ooga_booga" }, "/$test_var", test_lut) -- Test absolute varpath lookup
-- test_split({ "test", "catalyst", "test_feature", "config", "ooga_booga" }, "$test_var", test_lut) -- Test relative varpath lookup
-- test_split({ "home", ".config", "test_feature" }, "$install_target", test_lut) -- Test parent path

-- test_split({ "ooga_booga", "ooga_booga" }, "///$test_var///$test_var", test_lut) -- Test weird path
-- test_split({ "home", ".config" }, "$install_target/..", test_lut) -- Test parent path
-- test_split({ "home" }, "$install_target/../..", test_lut) -- Test parent path even more
-- test_split(nil, "../../../../../", test_lut) -- Test parents too far up the chain

-- test_split(nil, "$invalid/$also_invalid", test_lut)
-- test_split({ "~" }, "/././config/..///.///$install_target/../../", test_lut) -- ~ feels wrong, but ~ only expected to work if at the start of a path


-- Development shenanigans

-- path_utils.path_Resolve("$feature_config/one/$test_var/three", test_lut)

-- local index = path_utils.path_IndexFeature(path_utils.path_GetScriptDir() .. "/lua")
-- print("index:")
-- for _, v in ipairs(index) do
	-- print(" ", v)
-- end
-- local search = path_utils.path_GlobPath(index, "test/dummy/file")
-- print("search result:", search)

---

return test_result
