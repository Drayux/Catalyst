local dirload = require("lua.dirload")

-- Keep track of test stats for pretty output
local pass_count = 0
local failure_count = 0
local total_count = 0 -- May not equal pass + fail if a test fails to run

-- NOTE: This must only return one value or we may double-count a failed test
local function test_Runner(chunk, module, path)
	print(">>> Running test: " .. module .. " <<<")

	-- Support testing with both asserts and global return values
	local status, ret = pcall(chunk)
	if not status then
		print(ret)
		ret = false
	end

	-- Only count tests that have returned explicitly true or false
	if ret == false then
		failure_count = failure_count + 1
	elseif ret == true then
		pass_count = pass_count + 1

	else
		print("Test did not return boolean, assuming no failures")
		ret = true
	end

	total_count = total_count + 1
	print()
	return ret
end

local function test_Error(module, path, err)
	print(">>> Running test: " .. module .. " <<<")
	print("Error: " .. err)
	print()
	failure_count = failure_count + 1
	total_count = total_count + 1
	return false
end

-- Test execution sequence
local test_results = dirload("lua/test", {
	ignore = { "init.lua" },
	on_load = test_Runner,
	on_error = test_Error,
})
do
	local _esc = string.char(27, 91)
	local function pass_text(text)
		return string.format("%s32m%s%s0m", _esc, text, _esc)
	end
	local function fail_text(text)
		return string.format("%s31m%s%s0m", _esc, text, _esc)
	end

	local count_str = string.format("%d / %d", pass_count, total_count)
	local not_ran_count = total_count - pass_count - failure_count
	print("───────────────────────────────────")
	print("Test results: "
		.. ((failure_count > 0) and fail_text(count_str) or pass_text(count_str))
		.. ((not_ran_count == 0) and "" or (" (not ran: " .. tostring(not_ran_count) .. ")")))

	local test_output = false
	local pass = pass_text("PASS")
	local fail = fail_text("FAIL")
	for test, result in pairs(test_results) do
		test_output = true
		print(" │    >", test, result and pass or fail)
	end
	if not test_output then
		print("No tests ran :(")
	end
end
