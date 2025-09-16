--- TEST GLOBALS ---
TEST_OUTPUT = true
---

local test_result = true
local filesystem = require("lua.filesystem")

-- Some test "filesystems"
-- local _data = {
	-- cupcakes = {
		-- dog_toes = "tasty.txt",
		-- socks_in_mouth = "also_tasty.txt",
		-- waterfall = {
			-- riverbed = "double_tree.tar.gz"
		-- },
		-- hamburger = {
			-- mouth = "goated",
			-- ass = "silly",
		-- }
	-- },
	-- eggplant = {},
	-- headphone = {
		-- big_headphone = {
			-- sennheiser = "expensive",
			-- beyerdynamic = "bad_build_quality",
		-- }
	-- },
	-- sausage = "egg_mcmuffin.exe",
-- }
-- local _data = {
	-- recipes = {
		-- rice_and_beans = true,
		-- banana_bread = true,
		-- bacon_and_eggs = true,
	-- },
	-- furry_art = {
		-- ["dog1.png"] = true,
		-- ["dog2.png"] = true,
		-- ["dog3.png"] = true,
		-- ["dog4.png"] = true,
		-- ["dog5.png"] = true,
	-- }
-- }

assert(filesystem.path_GetHomeDir() == "/home", "Test expected home directory")

local test_lut = {
	feature_config = function()
		return "$catalyst_root/test_feature/config"
	end,
	catalyst_root = function()
		return "/test/catalyst"
	end,
	install_target = function()
		return "~/.config/test_feature"
	end,
	test_var = function()
		return "ooga_booga"
	end,
}

local function test_split(expected, ...)
	local input, lut = ...
	print(string.format("Testing path: `%s`", input))

	local test_pass = true
	-- local entry_count = 0
	local status, result = pcall(filesystem.path_Split, input, lut)
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

test_split({ "home", "Catalyst", "dotfiles" }) -- Test nil path (will probably fail on your computer)
test_split({ "home", "scripts", "pancakes" }, "~/scripts/pancakes") -- Test homedir lookup (will probably fail on your computer)
test_split(nil, "/$test_var") -- Test absolute varpath lookup with no LUT
test_split(nil, "$test_var") -- Test relative varpath lookup with no LUT

test_split({}, "/", test_lut) -- Test root
test_split({ "ooga_booga" }, "/$test_var", test_lut) -- Test absolute varpath lookup
test_split({ "test", "catalyst", "test_feature", "config", "ooga_booga" }, "$test_var", test_lut) -- Test relative varpath lookup
test_split({ "home", ".config", "test_feature" }, "$install_target", test_lut) -- Test parent path

test_split({ "ooga_booga", "ooga_booga" }, "///$test_var///$test_var", test_lut) -- Test weird path
test_split({ "home", ".config" }, "$install_target/..", test_lut) -- Test parent path
test_split({ "home" }, "$install_target/../..", test_lut) -- Test parent path even more
test_split(nil, "../../../../../", test_lut) -- Test parents too far up the chain

test_split(nil, "$invalid/$also_invalid", test_lut)
test_split({ "~" }, "/././config/..///.///$install_target/../../", test_lut) -- ~ feels wrong, but ~ only expected to work if at the start of a path

-- local splits = filesystem.path_Split("$install_target", test_lut)
-- filesystem:AddFile(splits, "da_linku")
-- filesystem:AddFile("/home/.config/crazy_hamburger", "da_linku_2")
-- filesystem:Print()

-- filesystem.path_Resolve("$feature_config/one/$test_var/three", test_lut)

local index = filesystem.path_IndexFeature("/home/Catalyst/lua")
print("index:")
for _, v in ipairs(index) do
	print(" ", v)
end
-- local search = filesystem.path_GlobDir(index, "test")
-- print("search results:")
-- for _, v in ipairs(search) do
	-- print(" ", v)
-- end
-- local search = filesystem.path_GlobDir(index, "options.lua")
local search = filesystem.path_GlobDir(index, "test/dummy/file")
print("search result:", search)
print(filesystem.path_FileName(index, search))

return test_result
