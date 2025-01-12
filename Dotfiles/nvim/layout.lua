-- >>> layout.lua: Prepare keymap as an auto-event

-- For details, see: cheatsheet.svg
-- vim.o.langmap is another compelling option for accomplishing this
-- > However, for any purpose other than swapping some keys, it is likely to complicate this configuration substantially
-- > - O-pending types (yIw, dAb, etc.) will look for the moved key
-- > - Custom behavior requires the newly mapped key to be specified (for example, if swapping Q and B but I don't want B to mean macros, then all of the vim.keymap calls need to use "Q" even though we are modifying the B key)

local GLOBAL = "" -- All modes except INSERT
local OBJECT = "o" -- Operator-pending mode
local NORMAL = "n" -- Normal mode
local INSERT = "i" -- Insert mode
local VISUAL = "v" -- Visual mode

local NOP = "<nop>"

local defaultOpts = {
	noremap = true, -- Don't recurse binds
	silent = true, -- Suppress status message
}

local exprOpts = {
	noremap = true, -- Don't recurse binds
	silent = true, -- Suppress status message
	expr = true, -- Mapping is an expression
}

-- >>> Key map shorthand globals
function map(mode, key, bind)
	vim.keymap.set(mode, key, bind, defaultOpts)
end

function mapcmd(map, cmd)
	local bind = "<leader>" .. map
	local command = "<cmd>" .. cmd .. "<cr>"
	local opts = {
		noremap = true,
		silent = true
	}
	vim.keymap.set("n", bind, command, opts)
end
-- >>>

-- >> KEYMAP CALLBACK <<
local setDefaultKeymap = function()
	-- NUMBER ROW
	-- > GRAVE: Macros
	map(GLOBAL, "`", "@")
	map(GLOBAL, "~", "q")
	-- > 1/2: Prev/Next Buffer
	map(GLOBAL, "!", NOP) -- (symmetry)
	map(GLOBAL, "@", NOP)
	map(NORMAL, "!", "<cmd>bp<cr>")
	map(NORMAL, "@", "<cmd>bn<cr>")
	-- > 3: Lookup Definition (TODO)
	-- > 4: Repeat Find (last searched character)
	map(GLOBAL, "$", ";")
	-- > 5: Repeat Last `:s` Replacement
	map(GLOBAL, "%", "&")
	-- > 6: Invert Case
	map(GLOBAL, "^", "~")
	-- > 7: Join Lines
	map(GLOBAL, "&", "J")
	-- > 8: Change entire line
	-- map(NORMAL, "*", "_d0C")
	map(NORMAL, "*", "_d0\"8C")
	map(VISUAL, "*", "\"8C") -- (symmetry)
	-- > 9: Replace Mode
	map(GLOBAL, "(", "R")
	-- > 0: Repeat command
	map(GLOBAL, "0", ".")
	-- TODO: `)` for ????

	-- QWERTY ROW
	-- > TAB: Completion
	map(GLOBAL, "<tab>", NOP) -- (TODO)
	-- > Q: [Motion] Word (back)
	map(GLOBAL, "q", "b")
	map(GLOBAL, "Q", "B")
	-- > W: [Motion] Word (forward)
	-- (default)
	-- > E: [Motion] Word End (forward)
	-- (default)
	-- > R: [Motion] Find char (forward)
	map(GLOBAL, "r", "f")
	map(GLOBAL, "R", ",")
	-- > T: [Motion] Find char (till)
	-- (default)
	-- > Y: Cut (don't shoot me for this lmao)
	map(GLOBAL, "y", "d")
	map(GLOBAL, "Y", "D")
	-- > U: Change (yeah, it's still gonna get weirder)
	map(GLOBAL, "u", "c")
	map(GLOBAL, "U", "C")
	map(GLOBAL, "<C-u>", "s")
	-- > I: Insert Mode
	map(GLOBAL, "I", "a")
	map(GLOBAL, "<C-i>", "A")
	-- > O: Open Line
	map(OBJECT, "o", "a")
	-- > P: Paste
	-- (default)
	-- > [: Terminal Commands
	-- (TODO)
	
	-- HOME ROW
	-- > A: [Motion] Start of Line
	map(GLOBAL, "a", "_")
	map(GLOBAL, "A", "0")
	map(OBJECT, "a", "_") -- (motion symmetry)
	map(OBJECT, "A", "0")
	-- > S: [Motion] End of Line
	map(GLOBAL, "s", "g_")
	map(GLOBAL, "S", "$")
	map(OBJECT, "s", "g_") -- (motion symmetry)
	map(OBJECT, "S", "$")
	-- > D: [Motion] Match Bracket
	map(GLOBAL, "d", "%")
	map(GLOBAL, "D", "<C-v>") -- Visual mode (block)
	-- > F: Visual Mode
	map(GLOBAL, "f", "v")
	map(GLOBAL, "F", "V")
	-- > G: Copy
	vim.cmd.unmap("gc")
	vim.cmd.unmap("gcc")
	map(NORMAL, "g", "y") -- (fights with _defaults)
	map(VISUAL, "g", "y$")
	map(GLOBAL, "G", "Y$") -- (D/C symmetry)
	-- > H: Left
	map(GLOBAL, "H", "<C-e>") -- Buffer view down
	map(GLOBAL, "<C-h>", "<cmd>vertical resize -2<cr>")
	-- > J: Down
	map(GLOBAL, "J", "<C-d>") -- Jump page down (1/2)
	map(GLOBAL, "<C-j>", "<cmd>resize +2<cr>")
	-- > K: Up
	map(GLOBAL, "K", "<C-u>") -- Jump page up (1/2)
	map(GLOBAL, "<C-k>", "<cmd>resize -2<cr>")
	-- > L: Right
	map(GLOBAL, "L", "<C-y>") -- Buffer view up
	map(GLOBAL, "<C-l>", "<cmd>vertical resize +2<cr>")
	-- > ;: Map leader (set to No-Op here)
	map(GLOBAL, ";", NOP)
	map({ GLOBAL, INSERT }, "<C-;>", "<C-c>:") -- Open command from anywhere (this may conflict with the default configuration of `ibus`)
	-- > ': Register access
	map(GLOBAL, "'", "\"")
	map(GLOBAL, "\"", [["p :reg <bar> exec 'normal! "'.input('Paste >> ').'p'<CR>]]) -- List register contents
	-- > Enter: No-Op
	map(GLOBAL, "<enter>", NOP)

	-- BOTTOM ROW
	-- > Z: Fold operations
	map(GLOBAL, "Z", "zi") -- Toggle folds
	-- > X: Editor (eXtra) operations
	-- TODO: Increase/decrease numbers
	-- TODO: Delete and paste but don't change register contents 
	local indent = function(inc, mode)
		local motion = "<<"
		local ext = ""
		if (mode == VISUAL) then
			motion = inc and ">"
				or "<"
			ext = "gv"
		elseif inc then
			motion = ">>"
		end
		return function()
			local count = tostring(vim.v.count)
			return count .. motion .. ext
		end
	end
	map(GLOBAL, "x", NOP) -- Remove default for subcommands instead
	map(NORMAL, "X", "==") -- Fix whitespace
	map({ GLOBAL, INSERT }, "<C-x>", "<C-o>")
	map(NORMAL, "xb", "==")
	map(VISUAL, "X", "=") -- (symmetry)
	map(VISUAL, "xb", "=")
	-- TODO: xc for comment (with comment plugin)
	-- TODO: Visual mode equivalent/Count support
	map(NORMAL, "xo", "o<esc>k") -- Add line below
	map(NORMAL, "xO", "ko<esc>j<C-e>") -- Add line above
	--------
	vim.keymap.set(GLOBAL, "xj", function()
			local count = tostring(vim.v.count)
			return "<cmd>m+" .. count .. "<cr>"
		end, exprOpts)
	vim.keymap.set(GLOBAL, "xk", function()
			local count = tostring(vim.v.count + 1)
			return "<cmd>m-" .. count .. "<cr>"
		end, exprOpts)
	vim.keymap.set(NORMAL, "xm", indent(true, NORMAL), exprOpts)
	vim.keymap.set(NORMAL, "xn", indent(false, NORMAL), exprOpts)
	vim.keymap.set(VISUAL, "xm", indent(true, VISUAL), exprOpts)
	vim.keymap.set(VISUAL, "xn", indent(false, VISUAL), exprOpts)
	map(VISUAL, "n", "<gv") -- "Stay" in visual mode
	map(VISUAL, "m", ">gv")
	-- > C: Replace
	map(GLOBAL, "c", "r")
	map(GLOBAL, "C", "x")
	map(VISUAL, "<C-c>", "<esc>") -- (v-block symmetry)
	-- > V: Window Navigation
	map(GLOBAL, "v", NOP) -- Remove default for subcommands instead
	-- TODO: `V` for window selection popup (plugin)
	map(NORMAL, "vh", "<C-w>h") -- Window navigation
	map(NORMAL, "vj", "<C-w>j")
	map(NORMAL, "vk", "<C-w>k")
	map(NORMAL, "vl", "<C-w>l")
	map(NORMAL, "vvh", "<cmd>leftabove vs<cr>")
	map(NORMAL, "vvj", "<cmd>rightbelow sp<cr>")
	map(NORMAL, "vvk", "<cmd>leftabove sp<cr>")
	map(NORMAL, "vvl", "<cmd>rightbelow vs<cr>")
	map(NORMAL, "vvq", "<cmd>only<cr>")
	-- > B: Buffer Navigation
	map(GLOBAL, "b", "g")
	map(GLOBAL, "B", "G")
	map(GLOBAL, "bg", NOP) -- (this subcommand does not move automagically)
	map(GLOBAL, "bb", "gg")
	-- > N: Search Navigation
	map(NORMAL, "n", "nzz") -- Center result on screen
	map(NORMAL, "N", "Nzz")
	map(GLOBAL, "<C-n>", "<cmd>noh<cr>")
	-- > M: Mark Navigation
	map(GLOBAL, "m", "'")
	map(GLOBAL, "M", "m")
	-- > ,: Undo
	map(GLOBAL, ",", "u")
	map(GLOBAL, "<", "U")
	-- TODO: `Ctrl-,` for undo tree (plugin)
	-- > .: Redo
	map(GLOBAL, ".", "<C-r>")
	-- TODO: `>` for redo line
	-- > /: Search
	map(GLOBAL, "?", "*zz") -- Search word at cursor
	map(GLOBAL, "<C-/>", "*0ggnzt") -- ^^Same but from the top

	-- CONTROL ROW
	-- > Arrows: Selection/Navigation
	map({ GLOBAL, INSERT }, "<S-left>", "<C-w>h")
	map({ GLOBAL, INSERT }, "<S-down>", "<C-w>j")
	map({ GLOBAL, INSERT }, "<S-up>", "<C-w>k")
	map({ GLOBAL, INSERT }, "<S-right>", "<C-w>l")
	map(NORMAL, "<C-left>", "vb") -- Recreation of `Ctrl-Arrow`
	map(VISUAL, "<C-left>", "b")
	map(NORMAL, "<C-down>", "vj")
	map(VISUAL, "<C-down>", "j")
	map(NORMAL, "<C-up>", "vk")
	map(VISUAL, "<C-up>", "k")
	map(NORMAL, "<C-right>", "vw")
	map(VISUAL, "<C-right>", "w")
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = setDefaultKeymap
})
