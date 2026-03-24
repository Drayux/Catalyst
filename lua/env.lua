--- env.lua - Static script environment variables

-- USAGE: Feature spec global variable namespace (env table is shared for all
-- 	features; built at runtime; managed internally)
-- STATE: Singleton instance; values held by this module
-- RTYPE: Module (API table -> instance)
-- NOTES:
-- 	  > Recommended to initially load this with pcall() for a "friendly" exit
-- 		if the script does not appear to be running in the correct working
-- 		directory. Possible refactor down the road. (TODO)

-- It is necessary to obtain the directory of the repo
local repo_dir = os.getenv("PWD")

-- Assert that this is really the right directory
-- TODO: Consider improving this; It work great for the current scope, but it
-- may prove obnoxous if expanding the functionality of this utility
do
	local errmsg = "Failed to get repo directory path"
	assert(repo_dir, errmsg)

	local gitignore_file = io.open(repo_dir .. "/.gitignore")
	assert(gitignore_file, errmsg)
	assert(gitignore_file:read():match("^(#catalyst_repo_assertion)$"), errmsg)

	gitignore_file:close()
end

local user_home = os.getenv("HOME")
-- Ensure $HOME is defined; Home path will always be at least `/home` on any of
-- my systems, hence I assert at least that many characters
assert((type(user_home) == "string") and (#user_home >= 5),
	"Failed to resolve user's $HOME directory")
assert((user_home ~= "/root"),
	"Current user appears to be ROOT; avoid running with doas / sudo")

--
local __env = {
	script_dir = repo_dir,
	dotfile_root = repo_dir .. "/dotfiles",
	user_home = user_home,
	--
	xdg_config = function()
		print("TODO: XDG config dir")
		return user_home .. "/.config"
	end,
	xdg_data = function()
		print("TODO: XDG data dir (.local)")
		return user_home .. "/.local"
	end
}
local __envcache = {}
local __saved = {} -- Spec-defined globals
--

local Module = {}
-- Metatable for 'JIT' variable resolution
Module.__index = function(_, specvar)
	if not __envcache[envvar] then
		local gen = __env[specvar]
		if not gen then
			-- Defined environment vars stomp spec globals
			return __saved[specvar]

		-- Save the output so the generator is called only once
		elseif type(gen) == "function" then
			__envcache[specvar] = gen()
		else
			return gen
		end
	end

	return __envcache[specvar]
end
Module.__newindex = function(_, specvar, value)
	assert(not __saved[specvar],
		string.format("Redefinition of spec global `%s` (`%s`)", specvar, tostring(value)))
	__saved[specvar] = value
end

return setmetatable({}, Module)
