local M = {}

---@class Options
local defaults = {
	events = {
		press = { "CursorMoved", "TextChangedI", "TextChangedP" },
	},
	sounds = {
		press = "~/downloads/sounds_default_keyany.wav",
	},
	max_parallel_sounds = 3,
	randomize = {
		volume = {
			enable = true,
			min = 0.75,
			max = 1,
		},
		speed = {
			enable = true,
			min = 0.75,
			max = 1,
		},
	},
}

---@type Options
M.options = {}

---@param options? Options
function M.setup(options)
	M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

M.setup()

return M
