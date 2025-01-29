-- >>> layout.lua: Prepare keymap as an auto-event

-- For details, see: cheatsheet.svg
-- vim.o.langmap is another compelling option for accomplishing this
-- > However, for any purpose other than swapping some keys, it is likely to complicate this configuration substantially
-- > - O-pending types (yIw, dAb, etc.) will look for the moved key
-- > - Custom behavior requires the newly mapped key to be specified (for example, if swapping Q and B but I don't want B to mean macros, then all of the vim.keymap calls need to use "Q" even though we are modifying the B key)

local NORMAL = "n" -- Normal mode
local INSERT = "i" -- Insert mode
local VISUAL = "v" -- Visual mode
local OBJECT = "o" -- Operator-pending mode
-- >>>
local EDITOR = { "n", "v" } -- "Editor" modes (normal, visual, select)
local ACTIVE = { "n", "i", "v" } -- "Interactive" modes (normal, visual, select, and insert)
local MOTION = "" -- "Motion" modes (normal, visual, select, and operator-pending)
local GLOBAL = { "n", "i", "c", "v", "o", "t", "l" } -- All supported modes (dangerous)
-- > See | map-table |

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
	map(EDITOR, "`", "@")
	map(EDITOR, "~", "q")
	-- > 1/2: Prev/Next Buffer
	map(NORMAL, "!", "<cmd>bp<cr>") -- (only supported in normal mode)
	map(NORMAL, "@", "<cmd>bn<cr>")
	-- > 3: Lookup Definition (TODO)
	-- > 4: Repeat Find (last searched character)
	map(MOTION, "$", ";")
	-- > 5: Repeat Last `:s` Replacement
	map(EDITOR, "%", "&")
	-- > 6: Invert Case
	map(EDITOR, "^", "~")
	-- > 7: Join Lines
	map(EDITOR, "&", "J")
	-- > 8: Change entire line
	-- map(NORMAL, "*", "_d0C")
	map(NORMAL, "*", "_d0\"8C")
	map(VISUAL, "*", "\"8C") -- (symmetry)
	-- > 9: Replace Mode
	map(EDITOR, "(", "R")
	-- > 0: Repeat command
	map(EDITOR, "0", ".")
	-- TODO: `)` for ????

	-- QWERTY ROW
	-- > TAB: Completion
	-- (TODO)
	-- > Q: [Motion] Word (back)
	if not vim.g.spider_enabled then
		map(MOTION, "q", "b")
	end
	map(MOTION, "Q", "B")
	-- > W: [Motion] Word (forward)
	-- (default)
	-- > E: [Motion] Word End (forward)
	-- (default)
	-- > R: [Motion] Find char (forward)
	map(MOTION, "r", "f")
	map(MOTION, "R", ",")
	-- > T: [Motion] Find char (till)
	-- (default)
	-- > Y: Cut (don't shoot me for this lmao)
	map(MOTION, "y", "d") -- (motion for `yy` behavior)
	map(EDITOR, "Y", "D")
	-- > U: Change (yeah, it's still gonna get weirder)
	map(MOTION, "u", "c")
	map(EDITOR, "U", "C")
	map(EDITOR, "<C-u>", "s")
	-- > I: Insert Mode
	map(NORMAL, "I", "a") -- (Normal mode only because of V-Block I)
	map(NORMAL, "<C-i>", "A")
	-- (TODO - Consider visual mode -> i for yank and move to insert mode)
	-- > O: Open Line
	map(OBJECT, "o", "a")
	-- > P: Paste
	-- (default)
	-- (TODO - O-pending comPlete aka...I forgot; something with I -> O -> P for "most outer")
	-- ^^ Could also include something like yph for start of line until cursor
	-- > [: Terminal Commands
	-- (TODO)
	
	-- HOME ROW
	-- > A: [Motion] Start of Line
	map(MOTION, "a", "_")
	map(MOTION, "A", "0")
	-- > S: [Motion] End of Line
	map(MOTION, "s", "g_")
	map(MOTION, "S", "$")
	-- > D: [Motion] Match Bracket
	map(EDITOR, "d", "%")
	map(OBJECT, "d", "b")
	map(EDITOR, "D", "<C-v>") -- Visual mode (block)
	-- > F: Visual Mode
	map(EDITOR, "f", "v")
	map(EDITOR, "F", "V")
	-- > G: Copy
	vim.cmd.unmap("gc")
	vim.cmd.unmap("gcc")
	map(NORMAL, "g", "y") -- (fights with _defaults)
	map(NORMAL, "gg", "yy")
	map(NORMAL, "G", "y$") -- (Delete/Change symmetry - |Y-default|)
	map(VISUAL, "g", "y")
	map(VISUAL, "G", "Y")
	-- > H: Left
	map(EDITOR, "H", "<C-e>") -- Buffer view down
	map(ACTIVE, "<C-h>", "<cmd>vertical resize -2<cr>")
	-- > J: Down
	map(EDITOR, "J", "<C-d>") -- Jump page down (1/2)
	map(ACTIVE, "<C-j>", "<cmd>resize +2<cr>")
	-- > K: Up
	map(EDITOR, "K", "<C-u>") -- Jump page up (1/2)
	map(ACTIVE, "<C-k>", "<cmd>resize -2<cr>")
	-- > L: Right
	map(EDITOR, "L", "<C-y>") -- Buffer view up
	map(ACTIVE, "<C-l>", "<cmd>vertical resize +2<cr>")
	-- > ;: Map leader (set to No-Op here)
	vim.cmd.unmap(";")
	map(ACTIVE, "<C-;>", "<C-c>:") -- Open command from anywhere (this may conflict with the default configuration of `ibus`)
	-- > ': Register access
	map(EDITOR, "'", "\"")
	map(EDITOR, "''", "\"+") -- Shortcut to use system clipboard (plus register)
	map(EDITOR, "\"", [["p :reg <bar> exec 'normal! "'.input('Paste >> ').'p'<CR>]]) -- List register contents
	-- > Enter: No-Op
	map(EDITOR, "<enter>", NOP)

	-- BOTTOM ROW
	-- > Z: Fold operations
	map(EDITOR, "Z", "zi") -- Toggle folds
	-- > X: Editor (eXtra) operations
	-- TODO: Increase/decrease numbers
	-- TODO: Delete and paste but don't change register contents 
	local indent = function(inc, mode)
		local motion = "<<"
		local ext = ""
		if (mode == VISUAL) then
			motion = inc and ">"
				or "<"
			ext = "gv" -- Return to visual mode with previous selection
		elseif inc then
			motion = ">>"
		end
		return function()
			local count = tostring(vim.v.count)
			return count .. motion .. ext
		end
	end
	map(EDITOR, "x", NOP) -- Remove default for subcommands instead
	map(NORMAL, "X", "==") -- Fix whitespace
	map(ACTIVE, "<C-x>", "<C-o>")
	map(NORMAL, "xb", "==")
	map(VISUAL, "X", "=") -- (symmetry)
	map(VISUAL, "xb", "=")
	-- TODO: Visual mode equivalent/Count support
	map(NORMAL, "xo", "o<esc>k") -- Add line below
	map(NORMAL, "xO", "ko<esc>j<C-e>") -- Add line above
	--------
	vim.keymap.set(EDITOR, "xj", function()
			local count = tostring(vim.v.count)
			return "<cmd>m+" .. count .. "<cr>"
		end, exprOpts)
	vim.keymap.set(EDITOR, "xk", function()
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
	map(EDITOR, "c", "r")
	map(EDITOR, "C", "x")
	map(VISUAL, "<C-c>", "<esc>") -- (v-block symmetry)
	-- > V: Window Navigation
	map(EDITOR, "v", NOP) -- Remove default for subcommands instead
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
	-- map(EDITOR, "b", "g")
	-- map(EDITOR, "bg", NOP) -- (this subcommand does not move automagically)
	map(EDITOR, "b", NOP)
	map(EDITOR, "bm", "zt")
	map(EDITOR, "bb", "zz")
	map(EDITOR, "bn", "zb")
	map(EDITOR, "B", "gg")
	map(EDITOR, "<C-b>", "G")
	-- > N: Search Navigation
	map(NORMAL, "n", "nzz") -- Center result on screen
	map(NORMAL, "N", "Nzz")
	map(ACTIVE, "<C-n>", "<cmd>noh<cr>")
	-- > M: Mark Navigation
	map(EDITOR, "m", "'")
	map(EDITOR, "M", "m")
	-- > ,: Undo
	map(EDITOR, ",", "u")
	map(EDITOR, "<", "U")
	-- TODO: `Ctrl-,` for undo tree (plugin)
	-- > .: Redo
	map(EDITOR, ".", "<C-r>")
	-- TODO: `>` for redo line
	-- > /: Search
	map(EDITOR, "?", "*zz") -- Search word at cursor
	map(EDITOR, "<C-/>", "*0ggnzt") -- ^^Same but from the top

	-- CONTROL ROW
	-- > Arrows: Selection/Navigation
	map(EDITOR, "<S-left>", "<C-w>h")
	map(EDITOR, "<S-down>", "<C-w>j")
	map(EDITOR, "<S-up>", "<C-w>k")
	map(EDITOR, "<S-right>", "<C-w>l")
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
