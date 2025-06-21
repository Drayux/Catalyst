local binds = require("editor.binds")

local NORMAL = binds.NORMAL
local INSERT = binds.INSERT
local VISUAL = binds.VISUAL
local OBJECT = binds.OBJECT
local EDITOR = binds.EDITOR
local ACTIVE = binds.ACTIVE
local MOTION = binds.MOTION
local GLOBAL = binds.GLOBAL

-- >> NUMBER ROW
local rowNumbers = function()
	-- > GRAVE: Macros
	binds.set(EDITOR, "`", "@")
	binds.set(EDITOR, "~", "q")
	-- > 1/2: Prev/Next Buffer
	binds.set(NORMAL, "!", "<cmd>bp<cr>") -- (only supported in normal mode)
	binds.set(NORMAL, "@", "<cmd>bn<cr>")
	-- > 3/4: Repeat Find (last searched character)
	-- binds.set(NORMAL, "=", ";") -- TODO: What was this?
	binds.set(MOTION, "$", ";")
	-- > 5: Match parentheses
	-- (default)
	-- > 6: Invert Case
	binds.set(EDITOR, "^", "~")
	-- > 7: Join Lines
	binds.set(EDITOR, "&", "J")
	-- > 8: Change entire line
	-- binds.set(NORMAL, "*", "_d0C")
	binds.set(NORMAL, "*", "_d0\"8C")
	binds.set(VISUAL, "*", "\"8C") -- (symmetry)
	-- > 9: Replace Mode
	binds.set(EDITOR, "(", "R")
	-- > 0: Repeat Last `:s` Replacement
	binds.set(EDITOR, ")", "&")
	-- > (*actual) 0: Repeat command
	binds.set(EDITOR, "0", ".")
	-- > MINUS: No idea ??? (TODO)
	-- ...
	-- > EQUALS: Lookup Definition (TODO)
	-- ...
end

-- >> QWERTY ROW
local rowQwerty = function()
	-- > TAB: Completion
	-- (TODO)
	-- > Q: [Motion] Word (back)
	if not vim.g.spider_enabled then
		binds.set(MOTION, "q", "b")
	end
	binds.set(MOTION, "Q", "B")
	-- > W: [Motion] Word (forward)
	-- (default)
	-- > E: [Motion] Word End (forward)
	-- (default)
	-- > R: [Motion] Find char (forward)
	binds.set(MOTION, "r", "f")
	binds.set(MOTION, "R", "F")
	-- > T: [Motion] Find char (till)
	-- (default)
	-- > Y: Cut (don't shoot me for this lmao)
	binds.set(MOTION, "y", "d") -- (motion for `yy` behavior)
	binds.set(EDITOR, "Y", "D")
	-- > U: Change (yeah, it's still gonna get weirder)
	binds.set(MOTION, "u", "c")
	binds.set(EDITOR, "U", "C")
	binds.set(EDITOR, "<C-u>", "s")
	-- > I: Insert Mode
	binds.set(NORMAL, "I", "a") -- (Normal mode only because of V-Block I)
	binds.set(NORMAL, "<C-i>", "A")
	-- (TODO - Consider visual mode -> i for yank and move to insert mode)
	-- > O: Open Line
	binds.set(VISUAL, "o", "a") -- Extend new selection names to visual mode
	-- binds.set(OBJECT, "iw", "iw")
	binds.set(OBJECT, "ow", "aw")
	-- > P: Paste
	-- (default)
	-- (TODO - O-pending comPlete aka...I forgot; something with I -> O -> P for "most outer")
	-- ^^ Could also include something like yph for start of line until cursor
	-- > [: Terminal Commands
	-- (TODO)
end

-- >> HOME ROW
local rowHome = function()
	-- > A: [Motion] Start of Line
	-- binds.set(EDITOR, "a", "_") -- This is an optional variant of the mapping below
	-- binds.set(OBJECT, "a", "0") -- ^^For some reason, the original sequence 'd_' deletes the entire line
	binds.set(MOTION, "a", "_") -- (TODO: Tweak to perfection)
	binds.set(MOTION, "A", "0")
	-- binds.set(NORMAL, "<C-a>", "<C-a>")
	-- > S: [Motion] End of Line
	binds.set(MOTION, "s", "g_")
	binds.set(MOTION, "S", "$")
	binds.set(NORMAL, "<C-s>", "<C-x>")
	-- > D: [Motion] Match Bracket
	if not vim.g.treesitter_enabled then
		-- Fallback binds when absent treesitter-textobjects
		-- NOTE: Treesitter's binds are set on plugin load, so these could be set normally
		-- > and then overridden -- The conditional is left in place merely as a visual
		-- > indicator that the current configuration rebinds these keys elsewhere
		binds.set(EDITOR, "D", "0k%")
		binds.set(EDITOR, "<C-d>", "<esc>vip")
	end
	binds.set(NORMAL, "d", "%") -- Match paren
	binds.set(VISUAL, "d", "o")
	-- > F: Visual Mode
	binds.set(EDITOR, "f", "v")
	binds.set(EDITOR, "F", "V")
	binds.set(EDITOR, "<C-f>", "<C-v>") -- Visual mode (block)
	-- > G: Copy
	vim.cmd.unmap("gc")
	vim.cmd.unmap("gcc")
	vim.cmd.unmap("gx")
	vim.cmd.xunmap("gra")
	binds.set(EDITOR, "g", "y") -- (fights with _defaults)
	binds.set(NORMAL, "gg", "yy")
	binds.set(NORMAL, "G", "y$") -- (Delete/Change symmetry - |Y-default|)
	binds.set(VISUAL, "G", "Y")
	-- > H: Left
	binds.set(EDITOR, "H", "<C-e>") -- Buffer view down
	binds.set(ACTIVE, "<C-h>", "<cmd>vertical resize -2<cr>")
	-- > J: Down
	binds.set(EDITOR, "J", "<C-d>") -- TODO: Treesitter node movement
	binds.set(ACTIVE, "<C-j>", "<C-d>") -- Jump page down (1/2)
	-- binds.set(ACTIVE, "<C-j>", "<cmd>resize +2<cr>")
	-- > K: Up
	binds.set(EDITOR, "K", "<C-u>") -- TODO: Treesitter node movement
	binds.set(ACTIVE, "<C-k>", "<C-u>") -- Jump page up (1/2)
	-- binds.set(ACTIVE, "<C-k>", "<cmd>resize -2<cr>")
	-- > L: Right (TODO - Fix me!)
	binds.set(EDITOR, "L", "<C-y>") -- Buffer view up
	binds.set(ACTIVE, "<C-l>", "<cmd>vertical resize +2<cr>")
	-- > ;: Map leader (set to No-Op here)
	binds.disable(EDITOR, ";")
	binds.set(ACTIVE, "<C-;>", "<C-c>:") -- Open command from anywhere (this may conflict with the default configuration of `ibus`)
	-- > ': Register access
	binds.set(EDITOR, "'", "\"")
	binds.set(EDITOR, "''", "\"+") -- Shortcut to use system clipboard (plus register)
	binds.set(EDITOR, "\"", [["p :reg <bar> exec 'normal! "'.input('Paste >> ').'p'<CR>]]) -- List register contents
	-- > Enter: No-Op
	binds.disable(EDITOR, "<enter>")
end

local rowBottom = function()
end

-- >> CONTROL ROW
local rowControl = function()
	-- > Arrows: Selection/Navigation
	binds.set(EDITOR, "<left>", "gh") -- Logical lines navigation (instead of newline delimited)
	binds.set(EDITOR, "<down>", "gj")
	binds.set(EDITOR, "<up>", "gk")
	binds.set(EDITOR, "<right>", "gl")
	binds.set(EDITOR, "<C-left>", "<C-w>h")
	binds.set(EDITOR, "<C-down>", "<C-w>j")
	binds.set(EDITOR, "<C-up>", "<C-w>k")
	binds.set(EDITOR, "<C-right>", "<C-w>l")
	binds.set(NORMAL, "<S-left>", "vb") -- Recreation of `Ctrl-Arrow`
	binds.set(VISUAL, "<S-left>", "b")
	binds.set(NORMAL, "<S-down>", "vj")
	binds.set(VISUAL, "<S-down>", "j")
	binds.set(NORMAL, "<S-up>", "vk")
	binds.set(VISUAL, "<S-up>", "k")
	binds.set(NORMAL, "<S-right>", "vw")
	binds.set(VISUAL, "<S-right>", "w")
end

-- TODO: This function is obsolete if a table of binds is used instead
-- TODO: @force - false: only set unset binds; true: overwrite all binds
local bindKeymap = function(_force)
	-- The maps are split up by keyboard row, not as a design nuance,
	-- but for code folding and location convenience
	rowNumbers()
	rowQwerty()
	rowHome()
	rowBottom()
	rowControl()
end


-- >> MODULE <<
local keymap = {
	_name = "defaults",
	_bind = bindKeymap,
	_overwrite = true, -- Hacky fix, set to false to only set unbound keys (TODO)
}

return binds._register(keymap)
