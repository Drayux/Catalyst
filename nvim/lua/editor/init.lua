-- This will just emulate the structure for symmetry
-- For now, this is fine, but it may become preferable to abstract the sub-
-- > components such that all API is called through this file
-- > This structure would then resemble that of buffers/
local module = {
	colors = require("editor.colors"),
	status = require("editor.status"),
	binds = require("editor.binds"),
}

return module
