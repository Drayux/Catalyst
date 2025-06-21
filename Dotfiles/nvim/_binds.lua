-- >>> keymap.lua: Prepare keymap as an auto-event

-- For details, see: cheatsheet.svg
-- vim.o.langmap is another compelling option for accomplishing this, but it would
-- > work best only with key swaps. For any other purpose, the effects are dubious

-- TODO: This file is target for a refactor
-- My temptation is to split up this "map" simliar to that of a color scheme where
-- all color palletes are given their own file in the themes/ directory.
-- Instead of each entry being exclusive, however, they would be additive.
-- I fear that this may only complicate the map instead of "consolidate", but if
-- adding a "which key" type of plugin, it may prove extra helpful, as a static
-- table could be referenced

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
	local expressions = require("buffer").action
	local funcstr = tostring(funcname)
	if expressions[funcstr] == nil then
		error("Buffer command `" .. tostring(funcstr) .. "` does not exist in lua/buffer.lua")
	end
	local mapping = function()
		vim.go.operatorfunc = "v:lua.require'buffer'.action." .. funcstr
		return expr or "g@l"
	end
	vim.keymap.set(mode, key, mapping, exprOpts)
end
-- >>>

-- >> KEYMAP CALLBACK <<
local setDefaultKeymap = function()
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
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = setDefaultKeymap
})
