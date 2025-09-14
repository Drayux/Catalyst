local filesystem = require("lua.filesystem")

local test_result = true

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
		return "dotfiles/test_feature/config"
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
	local status, result = pcall(filesystem.path_Split, input, lut)
	if status then
		for i, v in ipairs(result) do
			print("", v)
			if expected then
				test_pass = test_pass and (v == expected[i])
			else
				-- Test should have reached an error
				test_pass = false
				break
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

test_split({ "$feature_config" }) -- Test nil path
test_split({ "home", "scripts", "pancakes" }, "~/scripts/pancakes") -- Test homedir lookup (will probably fail on your computer)
test_split(nil, "/$testvar") -- Test absolute varpath lookup with no LUT
test_split({ "$feature_config", "$testvar" }, "$testvar") -- Test relative varpath lookup with no LUT
-- filesystem.path_Split(, test_lut)
-- filesystem.path_Split("./scripts/$test/waffles", test_lut)
-- filesystem.path_Split("/rootdir/more_pancakes", test_lut)
-- filesystem.path_Split("/$invalid/$also_invalid", test_lut)

return test_result
