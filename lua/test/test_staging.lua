--- TEST GLOBALS ---
TEST_OUTPUT = false
---

do return true end

local test_result = true
local tree = require("lua.staging")

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

-- assert(filesystem.path_GetHomeDir() == "/home", "Test expected home directory")

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

-- local splits = filesystem.path_Split("$install_target", test_lut)
-- filesystem:AddFile(splits, "da_linku")
-- filesystem:AddFile("/home/.config/crazy_hamburger", "da_linku_2")
-- filesystem:Print()

-- filesystem.path_Resolve("$feature_config/one/$test_var/three", test_lut)

local index = filesystem.path_IndexFeature(filesystem.path_GetScriptDir() .. "/lua")
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
local search = filesystem.path_GlobPath(index, "test/dummy/file")
print("search result:", search)

return test_result
