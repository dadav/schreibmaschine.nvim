local M = {}

---@class Options
local defaults = {
  -- set the active profile, which must be defined in `profiles`
  active_profile = "typewriter",
  -- group multiple events together, see `:h autocmd-events` for more informations
  -- if a non existent event is used, it's treated as a pattern (see `:h nvim_create_autocmd`)
  event_groups = {
    typing = { "InsertCharPre" },
    start = { "VimEnter" },
    exit = { "VimLeavePre" },
    save = { "BufWritePost" },
    load = { "BufReadPost" },
    create = { "BufNewFile" },
    suspend = { "VimSuspend" },
    resume = { "VimResume" },
  },
  -- profiles map events/keys to sounds
  profiles = {
    typewriter = {
      by_event_group = {
        -- if the filenames are relative, the will be resolved to:
        -- $PLUGIN/profiles/$profile/$filename
        typing = "key.wav",
      },
      by_key = {
        -- see `:h key-notation` for more keys
        ["<CR>"] = "enter.wav",
      },
    },
    kid = {
      by_event_group = {
        typing = { "pew1.mp3", "pew2.mp3" },
      },
      by_key = {
        ["<CR>"] = "enter.mp3",
      },
    },
    whistle = {
      by_event_group = {
        start = "start.mp3",
        exit = "exit.mp3",
      },
    },
    bubble = {
      by_event_group = {
        typing = "beep.wav",
        exit = "exit.wav",
      },
      by_key = {
        ["<CR>"] = "boop.wav",
      },
    },
    pop = {
      by_event_group = {
        typing = { "pop1.mp3", "pop2.mp3", "pop3.mp3" },
      },
    },
    instrumental = {
      by_event_group = {
        -- you can use multiple sounds for one event or key
        -- they will be randomly choosen
        typing = { "short1.mp3", "short2.mp3", "short3.mp3" },
        exit = "goodbye.mp3",
      },
      by_key = {
        ["<CR>"] = "enter.mp3",
      },
    },
    ["tts/en"] = {
      settings = {
        discard_when_busy = false,
        max_parallel_sounds = 1,
      },
      by_event_group = {
        save = "file_saved.mp3",
        load = "file_loaded.mp3",
        create = "file_created.mp3",
        start = "whats_up.mp3",
        exit = "goodbye.mp3",
        suspend = "dont_forget_me.mp3",
        resume = "glad_you_didnt_forget_me.mp3",
      },
    },
    ["tts/jp"] = {
      settings = {
        discard_when_busy = false,
        max_parallel_sounds = 1,
      },
      by_event_group = {
        save = "file_saved.mp3",
        load = "file_loaded.mp3",
        create = "file_created.mp3",
        start = "whats_up.mp3",
        exit = "goodbye.mp3",
        suspend = "dont_forget_me.mp3",
        resume = "glad_you_didnt_forget_me.mp3",
      },
    },
    nsfw = {
      settings = {
        max_parallel_sounds = 1,
        -- disable randomizations completely
        randomize = { {} },
      },
      by_event_group = {
        start = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      },
    },
  },
  -- the default profile options.
  -- overwrite them in profiles.$name.settings
  defaults = {
    -- kill remaining processes on VimLeavePre
    cleanup = false,
    -- if enabled, sounds will be discarded if `max_parallel_sounds` is reached
    discard_when_busy = true,
    -- limits the parallel sounds (mpv processes)
    max_parallel_sounds = 3,
    -- adds some randomization to the sounds
    randomize = {
      volume = {
        enable = true,
        -- 0 means silent, 1 means full volume
        min = 0.75,
        max = 1,
      },
      speed = {
        enable = true,
        -- 0.1 means super slow, 1 means normal speed, 2 means double
        min = 0.75,
        max = 1,
      },
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
