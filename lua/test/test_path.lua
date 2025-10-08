--- TEST GLOBALS ---
TEST_OUTPUT = false
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

--- DEVELOPMENT ---

-- test_split(nil, "/$test_var") -- Test absolute varpath lookup with no LUT
-- test_split(nil, "$test_var") -- Test relative varpath lookup with no LUT

-- path_utils.path_Resolve("$feature_config/one/$test_var/three", test_lut)

-- local index = path_utils.path_IndexFeature(path_utils.path_GetScriptDir() .. "/lua")
-- print("index:")
-- for _, v in ipairs(index) do
	-- print(" ", v)
-- end
-- local search = path_utils.path_GlobPath(index, "test/dummy/file")
-- print("search result:", search)

-- do return end

--- PATH OBJECT CREATION ---

local generic_lut = {
	feature_config = "$catalyst_root/test_feature/config",
	catalyst_root = "/catalyst",
	install_root = "~/.config/test_feature",
	user_home = "/home",
	test_var = "ooga_booga",
	long_var = "elbows/carpets/apples",
	recursive = "$recursive",
}

local function test_NewPath(expected, path_str)
	print(string.format("Testing new: `%s` (%s)", path_str, expected or " ~ error ~ "))

	local test_pass = true
	local status, path_obj = pcall(path, path_str, generic_lut)
	if status then
		if not expected then
			-- Test expected to error out and failed to do so
			test_pass = false

		else
			-- print(path_obj) -- For debugging
			test_pass = (expected == path_obj:String())
		end
	else
		test_pass = (expected == nil) -- true if a failure was expected 
	end

	print(" * " .. (test_pass and "PASS" or "FAIL"))
	if not test_pass then
		test_result = false
	end
end

test_NewPath("/", "/") -- Root dir
test_NewPath("apples", "./apples") -- Generic relative path
test_NewPath(".", "./") -- Current working directory
test_NewPath("/home/.config", "~/.config") -- Homedir path
test_NewPath("..", "../") -- Relative parent path
test_NewPath("/", "/dir_a/dir_b/dir_c/../../..") -- Absolute parent path
test_NewPath(nil, "/../") -- Parent of root dir (error expected)
test_NewPath("ooga_booga/ooga_booga", "$test_var/$test_var") -- Relative varpath lookup
test_NewPath("/catalyst/test_feature/config", "$feature_config") -- Recursive varpath lookup
test_NewPath(nil, "/absolute/$catalyst_root") -- Absolute varpath in middle (error expected)
test_NewPath(nil, "/absolute/$install_root") -- Absolute varpath in middle (error expected)
test_NewPath(nil, "$invalid/$also_invalid") -- Bad varpath lookup (error expected)
test_NewPath("/elbows", "/././config/..///.///$long_var/../../") -- Weird fuckin (but still valid) path syntax
test_NewPath(nil, "$recursive") -- Infinitely recursive varpath (error expected)

--- PATH APPEND OPERATION ---

local function test_AppendPath(expected, init_str, append_str)
	print(string.format("Testing append: `%s` + `%s` (%s)", init_str, append_str, expected or " ~ error ~ "))

	local test_pass = true
	local status, path_obj = pcall(path, init_str, generic_lut)
	if not status then
		-- Creating the path object failed, return early
		test_result = false
		print(" * FAIL")
		return
	end

	local status, new_path_obj = pcall(path_obj.Append, path_obj, append_str)
	if not status then
		test_pass = (expected == nil) -- true if a failure was expected 
	else
		-- print(new_path_obj) -- For debugging
		test_pass = (expected == new_path_obj:String())
	end

	print(" * " .. (test_pass and "PASS" or "FAIL"))
	if not test_pass then
		test_result = false
	end
end

test_AppendPath("apples/bananas", "./apples", "bananas") -- Generic append operation (relative)
test_AppendPath("apples", "apples/bananas", "..") -- Parent append operation (relative)
test_AppendPath("carrots", "apples/bananas/../../", "carrots") -- Parent in original path (accept_index logic)
test_AppendPath("/test_root/ooga_booga", "/test_root/oranges/", "../$test_var/") -- Append varpath
test_AppendPath(nil, "apples", "/carrots") -- Append absolute path (error expected)
test_AppendPath(nil, "/", "..") -- Append parent to root (error expected)

--- ABSOLUTE PATH RESOLUTION ---

local function test_AbsolutePath(expected, path_str)
	print(string.format("Testing absolute: `%s` (%s)", path_str, expected or " ~ error ~ "))

	local test_pass = true
	local status, path_obj = pcall(path, path_str, generic_lut)
	if not status then
		-- Creating the path object failed, return early
		test_result = false
		print(" * FAIL")
		return
	end

	local status, new_path_obj = pcall(path_obj.Absolute, path_obj)
	if not status then
		test_pass = (expected == nil) -- true if a failure was expected 
	else
		-- print(new_path_obj) -- For debugging
		test_pass = (expected == new_path_obj:String())
	end

	print(" * " .. (test_pass and "PASS" or "FAIL"))
	if not test_pass then
		test_result = false
	end
end

test_AbsolutePath("/home/catalyst", "/home/catalyst/") -- Path that is already absolute
test_AbsolutePath("/catalyst/test_feature/config", "$feature_config") -- Absolute varpath
test_AbsolutePath("/home/.config/test_feature", ".") -- Default working directory
test_AbsolutePath("/home/.config/test_feature/apples/oranges", "./apples/oranges") -- Subdir of working dir
test_AbsolutePath("/home/.config/ooga_booga", "./../$test_var") -- Varpath in working dir
test_AbsolutePath("/", "../../..") -- Absurd parent of default working directory
test_AbsolutePath(nil, "../../../../") -- Too many parents (error expected)

--- PATH INDEXING/SEARCH ---

-- TODO: Could use some tests once I'm sure of the implementation requirements
-- which would be revealed during the completion of the feature spec processing

local search_test_1 = path("/home/Projects/Catalyst/dotfiles/zsh/")
print(search_test_1.file) -- false

local search_test_2 = path("/home/Projects/Catalyst/dotfiles/zsh/config/config")
print(search_test_2.file) -- true

print("\nAttempting search 1:")
local search_test_1_search = search_test_1:Search("config/scripts")
for i, v in ipairs(search_test_1_search) do
	print(v)
end

print("\nAttempting search 2:") -- Still using search_test_1 var btw
local search_test_2_search = search_test_1:Search("config/config")
print(search_test_2_search)

---

return test_result
