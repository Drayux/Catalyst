local dirload = require("lua.dirload")

-- Global test utility functions
local _print = print
function print(...)
	-- show_output will be scoped to the test
	if TEST_OUTPUT then
		_print(...)
	end
end

-- TODO: Not sure yet what all I can do with this
-- local _assert = assert
-- function assert(statement, comment)
	-- _assert(statement, comment)
-- end

-- Keep track of test stats for pretty output
local pass_count = 0
local failure_count = 0
local total_count = 0 -- May not equal pass + fail if a test fails to run

-- NOTE: This must only return one value or we may double-count a failed test
local function test_Runner(chunk, module, path)
	TEST_OUTPUT = false -- Reset global test options

	_print(">>> Running test: " .. module .. " <<<")

	-- Support testing with both asserts and global return values
	local status, ret = pcall(chunk)
	if not status then
		_print(ret)
		ret = false
	end

	-- Only count tests that have returned explicitly true or false
	if ret == false then
		failure_count = failure_count + 1
	elseif ret == true then
		pass_count = pass_count + 1

	else
		_print("Test did not return a boolean")
		ret = true
	end

	total_count = total_count + 1
	print() -- Intentional use of remapped print
	return ret
end

local function test_Error(module, path, err)
	_print(">>> Running test: " .. module .. " <<<")
	_print("Error: " .. err)
	print() -- Intentional use of remapped print
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
	_print("───────────────────────────────────")
	_print("Test results: "
		.. ((failure_count > 0) and fail_text(count_str) or pass_text(count_str))
		.. ((not_ran_count == 0) and "" or (" (not ran: " .. tostring(not_ran_count) .. ")")))

	local test_output = false
	local pass = pass_text("PASS")
	local fail = fail_text("FAIL")
	for test, result in pairs(test_results) do
		test_output = true
		_print(" │    >", test, result and pass or fail)
	end
	if not test_output then
		_print("No tests ran :(")
	end
end
