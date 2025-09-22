-- Static script environment variables

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
assert((type(user_home) == "string") and (#user_home >= 5))

--
local module = {} -- For recursive lookups, if necessary
local environment = {
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
--


local _data = {}
return setmetatable(module, {
	-- Metatable for 'JIT' variable resolution
	__index = function(self, var)
		if not _data[var] then
			local gen = environment[var]
			if not gen then
				-- TODO: Might want to make this just a warning of sorts
				-- error(string.format("No environment variable `%s` exists", var))
			elseif type(gen) == "function" then
				_data[var] = gen()
			else
				return gen
			end
		end

		return _data[var]
	end,
	__newindex = function()
		error("Environment vars module is read-only")
	end
})
