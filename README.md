<h1 align="center">🔊schreibmaschine.nvim</h1>

<p align="center">
  <img src="logo.jpg" width="400" />
  <br />
  This plugin maps events and keys to sound files.
</p>

## ⭐Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "dadav/schreibmaschine.nvim",
  lazy = false,
  init = function()
    vim.keymap.set('n', '<leader>Tt', '<cmd>SchreibmaschineToggle<cr>')
    vim.keymap.set('n', '<leader>Tp', '<cmd>SchreibmaschineProfilePicker<cr>')
  end,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
}
```

### Requirements

- [mpv](https://github.com/mpv-player/mpv)

## 🎨 Configuration

```lua
{
  -- set the active profile, which must be defined in `profiles`
  active_profile = "typewriter",
  -- group multiple events together, see `:h autocmd-events` for more informations
  -- if a non existent event is used, it's treated as a pattern (see `:h nvim_create_autocmd`)
  event_groups = {
    yank = { "TextYankPost" },
    typing = { "InsertCharPre" },
    start = { "VimEnter" },
    exit = { "VimLeavePre" },
    save = { "BufWritePost" },
    load = { "BufReadPost" },
    create = { "BufNewFile" },
    suspend = { "VimSuspend" },
    resume = { "VimResume" },
    lazy_update = { "LazyUpdate" },
    lazy_clean = { "LazyClean" },
    lazy_check = { "LazyCheck" },
    lazy_reload = { "LazyReload" },
    lazy_install = { "LazyInstall" },
    lazy_sync = { "LazySync" },
  },
  -- profiles map events/keys to sounds
  profiles = {
    typewriter = {
      by_event_group = {
        -- if the filenames are relative, the will be resolved to:
        -- $PLUGIN/profiles/$profile/$filename
        typing = {
          "key1.mp3",
          "key2.mp3",
          "key3.mp3",
          "key4.mp3",
          "key5.mp3",
          "key6.mp3",
          "key7.mp3",
          "key8.mp3",
          "key9.mp3",
          "key10.mp3",
        },
        save = "save.mp3",
      },
      by_key = {
        -- see `:h key-notation` for more keys
        ["<CR>"] = "enter.mp3",
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
        typing = { "pop1.mp3", "pop2.mp3", "pop3.mp3", "pop4.mp3" },
      },
      by_key = {
        ["<CR>"] = "pop5.mp3",
        ["<ESC>"] = "pop6.mp3",
        ["<BS>"] = "pop7.mp3",
      },
    },
    fart = {
      by_event_group = {
        typing = { "fart1.mp3", "fart2.mp3" },
      },
      by_key = {
        ["<CR>"] = { "fart3.mp3", "fart4.mp3" },
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
      settings = {
        randomize = {
          order = {
            enable = true,
          },
        },
      },
    },
    ["tts/en"] = {
      settings = {
        discard_when_busy = false,
        max_parallel_sounds = 1,
        randomize = {
          volume = {
            enable = false,
          },
          speed = {
            enable = false,
          },
        },
      },
      by_event_group = {
        save = "file_saved.mp3",
        -- load = "file_loaded.mp3",
        create = "file_created.mp3",
        start = "whats_up.mp3",
        exit = "goodbye.mp3",
        suspend = "dont_forget_me.mp3",
        resume = "glad_you_didnt_forget_me.mp3",
        lazy_install = "install_complete.mp3",
        lazy_update = "update_complete.mp3",
        lazy_sync = "sync_complete.mp3",
        lazy_reload = "reload_complete.mp3",
        lazy_check = "check_complete.mp3",
      },
    },
    ["tts/jp"] = {
      settings = {
        discard_when_busy = false,
        max_parallel_sounds = 1,
        randomize = {
          volume = {
            enable = false,
          },
          speed = {
            enable = false,
          },
        },
      },
      by_event_group = {
        save = "file_saved.mp3",
        -- load = "file_loaded.mp3",
        create = "file_created.mp3",
        start = "whats_up.mp3",
        exit = "goodbye.mp3",
        suspend = "dont_forget_me.mp3",
        resume = "glad_you_didnt_forget_me.mp3",
        lazy_install = "install_complete.mp3",
        lazy_update = "update_complete.mp3",
        lazy_sync = "sync_complete.mp3",
        lazy_reload = "reload_complete.mp3",
        lazy_check = "check_complete.mp3",
      },
    },
    nsfw = {
      settings = {
        max_parallel_sounds = 1,
        -- disable randomizations completely
        randomize = { {} },
        cleanup = true,
      },
      by_event_group = {
        start = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      },
    },
  },
  -- the default profile options.
  -- overwrite them in profiles.$name.settings
  defaults = {
    -- default volume; may be changed by the randomize.volume settings
    -- 1 means 100%
    volume = 1,
    -- kill remaining processes on VimLeavePre
    cleanup = false,
    -- if enabled, sounds will be discarded if `max_parallel_sounds` is reached
    discard_when_busy = true,
    -- limits the parallel sounds (mpv processes)
    max_parallel_sounds = 3,
    -- adds some randomization to the sounds
    randomize = {
      -- randomize the volume of the sound file
      volume = {
        enable = true,
        -- 0 means silent, 1 means full volume
        min = 0.75,
        max = 1,
      },
      -- randomize the speed of the sound file
      speed = {
        enable = true,
        -- 0.1 means super slow, 1 means normal speed, 2 means double
        min = 0.75,
        max = 1,
      },
      -- if enabled, play the sounds in order (in a loop)
      order = {
        enable = false,
      },
      -- remember the played sound for the events or keys
      -- relevant if multiple sounds per event/key were configured
      persistent_assignment = {
        enable = false,
      },
    },
  },
}
```

## ⚡Commands

There are two commands you can use:

- **SchreibmaschineToggle**: Toggle the functionality of this plugin.
- **SchreibmaschineProfilePicker**: Start a profile selector.

There are no mappings shipped, you need to create them yourself
(for example in the `init` function, see the installation section).

## 🔑 License

[MIT](./LICENSE)
