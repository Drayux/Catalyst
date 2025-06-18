-- >>> layout.lua: Prepare keymap as an auto-event

-- For details, see: cheatsheet.svg
-- vim.o.langmap is another compelling option for accomplishing this, but it would
-- > work best only with key swaps. For any other purpose, the effects are dubious

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

function mapcmd(key, cmd)
	local bind = "<leader>" .. key
	local command = "<cmd>" .. cmd .. "<cr>"
	local opts = {
		noremap = true,
		silent = true
	}
	vim.keymap.set("n", bind, command, opts)
end

-- Expression functions are defined in lua/buffers.lua
-- NOTE: The expression option is not necessary for a mapping to lua code!
-- > It actually means that Neovim will run the binding returned by the function, or do nothing if it returns nil
-- > The advantage of this is to allow lua functions to be "dot-repeatable" (remapped to 0)
function mapexpr(mode, key, funcname, expr)
	local expressions = require("buffer").expressions
	local funcstr = tostring(funcname)
	if expressions[funcstr] == nil then
		error("Buffer command `" .. tostring(funcstr) .. "` does not exist in lua/buffer.lua")
	end
	local mapping = function()
		vim.go.operatorfunc = "v:lua.require'buffer'.expressions." .. funcstr
		return expr or "g@l"
	end
	vim.keymap.set(mode, key, mapping, exprOpts)
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
	-- > 3/4: Repeat Find (last searched character)
	map(NORMAL, "=", ";")
	map(MOTION, "$", ";")
	-- > 5: Match parentheses
	-- (default)
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
	-- > 0: Repeat Last `:s` Replacement
	map(EDITOR, ")", "&")
	-- > (*actual) 0: Repeat command
	map(EDITOR, "0", ".")
	-- > MINUS: No idea ??? (TODO)
	-- ...
	-- > EQUALS: Lookup Definition (TODO)
	-- ...

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
	map(MOTION, "R", "F")
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
	map(VISUAL, "o", "a") -- Extend new selection names to visual mode
	-- map(OBJECT, "iw", "iw")
	map(OBJECT, "ow", "aw")
	-- > P: Paste
	-- (default)
	-- (TODO - O-pending comPlete aka...I forgot; something with I -> O -> P for "most outer")
	-- ^^ Could also include something like yph for start of line until cursor
	-- > [: Terminal Commands
	-- (TODO)
	
	-- HOME ROW
	-- > A: [Motion] Start of Line
	-- map(EDITOR, "a", "_") -- This is an optional workaround for the mapping below
	-- map(OBJECT, "a", "0") -- For some reason, the original sequence 'd_' deletes the entire line
	map(MOTION, "a", "_") -- (TODO: Tweak to perfection)
	map(MOTION, "A", "0")
	-- map(NORMAL, "<C-a>", "<C-a>")
	-- > S: [Motion] End of Line
	map(MOTION, "s", "g_")
	map(MOTION, "S", "$")
	map(NORMAL, "<C-s>", "<C-x>")
	-- > D: [Motion] Match Bracket
	if not vim.g.treesitter_enabled then
		-- Fallback binds when absent treesitter-textobjects
		-- NOTE: Treesitter's binds are set on plugin load, so these could be set normally
		-- > and then overridden -- The conditional is left in place merely as a visual
		-- > indicator that the current configuration rebinds these keys elsewhere
		map(EDITOR, "D", "0k%")
		map(EDITOR, "<C-d>", "<esc>vip")
	end
	map(NORMAL, "d", "%") -- Match paren
	map(VISUAL, "d", "o")
	-- > F: Visual Mode
	map(EDITOR, "f", "v")
	map(EDITOR, "F", "V")
	map(EDITOR, "<C-f>", "<C-v>") -- Visual mode (block)
	-- > G: Copy
	vim.cmd.unmap("gc")
	vim.cmd.unmap("gcc")
	vim.cmd.unmap("gx")
	vim.cmd.xunmap("gra")
	map(EDITOR, "g", "y") -- (fights with _defaults)
	map(NORMAL, "gg", "yy")
	map(NORMAL, "G", "y$") -- (Delete/Change symmetry - |Y-default|)
	map(VISUAL, "G", "Y")
	-- > H: Left
	map(EDITOR, "H", "<C-e>") -- Buffer view down
	map(ACTIVE, "<C-h>", "<cmd>vertical resize -2<cr>")
	-- > J: Down
	map(EDITOR, "J", "<C-d>") -- TODO: Treesitter node movement
	map(ACTIVE, "<C-j>", "<C-d>") -- Jump page down (1/2)
	-- map(ACTIVE, "<C-j>", "<cmd>resize +2<cr>")
	-- > K: Up
	map(EDITOR, "K", "<C-u>") -- TODO: Treesitter node movement
	map(ACTIVE, "<C-k>", "<C-u>") -- Jump page up (1/2)
	-- map(ACTIVE, "<C-k>", "<cmd>resize -2<cr>")
	-- > L: Right (TODO - Fix me!)
	map(EDITOR, "L", "<C-y>") -- Buffer view up
	map(ACTIVE, "<C-l>", "<cmd>vertical resize +2<cr>")
	-- > ;: Map leader (set to No-Op here)
	map(EDITOR, ";", NOP)
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
	-- TODO: Delete and paste but don't change register contents 
	map(EDITOR, "x", NOP) -- Remove default for subcommands instead
	map(NORMAL, "X", "==") -- Fix whitespace
	map(ACTIVE, "<C-x>", "<C-o>")
	map(NORMAL, "xb", "==")
	map(VISUAL, "X", "=") -- (symmetry)
	map(VISUAL, "xb", "=")
	map(NORMAL, "xf", "gv")
	mapexpr(NORMAL, "xo", "insertLineBelow")
	mapexpr(NORMAL, "xO", "insertLineAbove")
	mapexpr(EDITOR, "xj", "moveLineDown")
	mapexpr(EDITOR, "xk", "moveLineUp")
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
	vim.keymap.set(NORMAL, "xm", indent(true, NORMAL), exprOpts)
	vim.keymap.set(NORMAL, "xn", indent(false, NORMAL), exprOpts)
	vim.keymap.set(VISUAL, "xm", indent(true, VISUAL), exprOpts)
	vim.keymap.set(VISUAL, "xn", indent(false, VISUAL), exprOpts)

	mapexpr(EDITOR, "xc", "commentLine")
	mapexpr(EDITOR, "xC", "uncommentLine")

		-- mapexpr(EDITOR, "xc", "commentLine")
		-- mapexpr(EDITOR, "xC", "uncommentLine")
		-- mapexpr(EDITOR, "xd", "commentBlock") (TODO)
		-- map(EDITOR, "xc", function()
			-- require("buffer").commentLine()
		-- end)
		-- vim.keymap.set(EDITOR, "xc", function()
			-- return require("vim._comment").operator()
		-- end, { expr = true, silent = true, noremap = true })
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
	map(NORMAL, "vvo", "<cmd>only<cr>")
	map(NORMAL, "vvp", "<C-w>=")
	map(NORMAL, "vvq", "<cmd>q<cr>")
	map(NORMAL, "vc", function()
			-- TODO: Consider adding autocommand to toggle whenever in insert mode
			local width = tonumber(vim.wo.colorcolumn) or 0
			vim.wo.colorcolumn = (width > 0) and "0" or "80"
			vim.cmd.redraw() -- Trigger neovim to redraw the window so the column shows immediately
		end)
	-- > B: Buffer Navigation
	-- TODO: b<any> for treesitter-textobjects jumping
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
	map(NORMAL, ",", "u")
	map(VISUAL, ",", "<esc>ugv")
	map(EDITOR, "<", "U")
	-- TODO: `Ctrl-,` for undo tree (plugin)
	-- > .: Redo
	map(NORMAL, ".", "<C-r>")
	map(VISUAL, ",", "<esc><C-r>gv")
	-- TODO: `>` for redo line
	-- > /: Search
	map(EDITOR, "?", "*zz") -- Search word at cursor
	map(EDITOR, "<C-/>", "*0ggnzt") -- ^^Same but from the top

	-- CONTROL ROW
	-- > Arrows: Selection/Navigation
	map(EDITOR, "<left>", "gh") -- Logical lines navigation (instead of newline delimited)
	map(EDITOR, "<down>", "gj")
	map(EDITOR, "<up>", "gk")
	map(EDITOR, "<right>", "gl")
	map(EDITOR, "<C-left>", "<C-w>h")
	map(EDITOR, "<C-down>", "<C-w>j")
	map(EDITOR, "<C-up>", "<C-w>k")
	map(EDITOR, "<C-right>", "<C-w>l")
	map(NORMAL, "<S-left>", "vb") -- Recreation of `Ctrl-Arrow`
	map(VISUAL, "<S-left>", "b")
	map(NORMAL, "<S-down>", "vj")
	map(VISUAL, "<S-down>", "j")
	map(NORMAL, "<S-up>", "vk")
	map(VISUAL, "<S-up>", "k")
	map(NORMAL, "<S-right>", "vw")
	map(VISUAL, "<S-right>", "w")
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = setDefaultKeymap
})
