local M = {}
local Counter = 0
local Config = require("schreibmaschine.config")

function M.play(sound)
	if sound == nil or Counter >= Config.options.max_parallel_sounds then
		return
	end

	local file = vim.fn.expand(sound)

	if not vim.fn.filereadable(file) then
		error("Can't read sound file: " .. sound)
	end

	-- Keep track of the spawned processes
	Counter = Counter + 1

	-- Determine speed
	local speed = 1
	if Config.options.randomize.speed.enable then
		speed = math.min(Config.options.randomize.speed.min + math.random(), Config.options.randomize.speed.max)
	end

	-- Determine volume
	local volume = 100
	if Config.options.randomize.volume.enable then
		volume = math.random(Config.options.randomize.volume.min * 100, Config.options.randomize.volume.max * 100)
	end

	-- Play the sound
	vim.loop.spawn("mpv", {
		args = { string.format("--speed=%f", speed), string.format("--volume=%d", volume), file },
		hide = true,
	}, function()
		Counter = Counter - 1
	end)
end

function M.setup(opts)
	require("schreibmaschine.config").setup(opts)

	for type, events in pairs(Config.options.events) do
		vim.api.nvim_create_autocmd(events, {
			callback = function()
				M.play(Config.options.sounds[type])
			end,
		})
	end
end

return M
