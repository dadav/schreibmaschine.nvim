local M = {}

-- Keep track of the running mpv instances
M.process_counter = 0
-- Userconfig
M.config = require("schreibmaschine.config")
-- Toggles the sounds
M.active = true
-- To access the internal sound files
M.profiles_dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/profiles"

---Play the given sound with mpv
---@param sound string
function M.play(sound)
  if sound == nil then
    return
  end

  if M.process_counter >= (M.profile_settings.max_parallel_sounds or 3) then
    if M.profile_settings.discard_when_busy then
      return
    else
      -- currently busy, try again in 200ms
      vim.defer_fn(function()
        M.play(sound)
      end, 200)
      return
    end
  end

  if not vim.fn.filereadable(sound) then
    error("Can't read sound file: " .. sound)
  end

  -- Keep track of the spawned processes
  M.process_counter = M.process_counter + 1

  -- Determine speed
  local speed = 1
  if
    M.profile_settings.randomize
    and M.profile_settings.randomize.speed
    and M.profile_settings.randomize.speed.enable
  then
    speed = math.min(
      (M.profile_settings.randomize.speed.min or 0) + math.random(),
      M.profile_settings.randomize.speed.max or 1
    )
  end

  -- Determine volume
  local volume = 100
  if
    M.profile_settings.randomize
    and M.profile_settings.randomize.volume
    and M.profile_settings.randomize.volume.enable
  then
    volume = math.random(
      (M.profile_settings.randomize.volume.min or 0) * 100,
      (M.profile_settings.randomize.volume.max or 1) * 100
    )
  end

  -- Play the sound
  local process, _ = vim.loop.spawn("mpv", {
    args = {
      "--no-config",
      "--no-video",
      string.format("--speed=%f", speed),
      string.format("--volume=%d", volume),
      sound,
    },
    -- relevant for windows
    hide = true,
  }, function()
    M.process_counter = M.process_counter - 1
  end)

  -- cleanup
  if M.profile_settings.cleanup and process ~= nil then
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function(_)
        vim.loop.process_kill(process)
      end,
    })
  end
end

---Start a profile picker ui
---@param cb function
function M.pick_profile(cb)
  local profiles = {}
  for key, _ in pairs(M.config.options.profiles) do
    table.insert(profiles, key)
  end
  table.sort(profiles)
  vim.ui.select(profiles, {
    prompt = "Profile:",
    format_item = function(item)
      return table.concat(vim.split(item, "_"), " ")
    end,
  }, function(item, _)
    cb(item)
  end)
end

---Toggle this plugin functionality
function M.toggle()
  M.active = not M.active
end

---Setup this plugin
---@param opts? Options
function M.setup(opts)
  require("schreibmaschine.config").setup(opts)

  M.profile = M.config.options.active_profile

  if M.config.options.profiles[M.profile] == nil then
    return vim.notify(
      string.format("Profile %s does not exist.", M.profile),
      vim.log.levels.ERROR,
      { title = "schreibmaschine.nvim" }
    )
  end

  vim.api.nvim_create_user_command("SchreibmaschineProfilePicker", function()
    M.pick_profile(function(item)
      if item ~= nil then
        M.profile = item
        M.configure()
      end
    end)
  end, {})

  vim.api.nvim_create_user_command("SchreibmaschineToggle", M.toggle, {})

  M.configure()
end

---Checks if the file exists in the internal profile directory
---@param given_path string
---@return string
function M.resolve_sound(given_path)
  -- Check if url
  if given_path:sub(1, 4) == "http" then
    return given_path
  end

  -- Check if file exist in profile dir
  local profile_file = vim.fn.expand(string.format("%s/%s/%s", M.profiles_dir, M.profile, given_path))
  if vim.fn.filereadable(profile_file) then
    return profile_file
  end
  return vim.fn.expand(given_path)
end

---Configures the necessary autocmds and listeners
function M.configure()
  -- Create profile settings
  M.profile_settings =
    vim.tbl_deep_extend("force", M.config.options.defaults, M.config.options.profiles[M.profile].settings or {})

  -- Put everything in a augroup
  local group = vim.api.nvim_create_augroup("Schreibmaschine", {})

  if M.config.options.profiles[M.profile].by_event_group ~= nil then
    for event_group, configured_events in pairs(M.config.options.event_groups) do
      -- Check if the profile has mapping for event_groups

      if M.config.options.profiles[M.profile].by_event_group[event_group] ~= nil then
        local events = {}
        local sounds = {}
        local one_or_more_sounds = M.config.options.profiles[M.profile].by_event_group[event_group]

        if type(one_or_more_sounds) == "string" then
          table.insert(sounds, M.resolve_sound(one_or_more_sounds))
        elseif type(one_or_more_sounds) == "table" then
          for _, s in pairs(one_or_more_sounds) do
            table.insert(sounds, M.resolve_sound(s))
          end
        end

        local play_sound = function()
          if M.active then
            M.play(sounds[math.random(#sounds)])
          end
        end

        -- Check if configured events exist, if not -> treat as pattern
        for _, v in pairs(configured_events) do
          if vim.fn.exists("##" .. v) == 1 then
            table.insert(events, v)
          else
            vim.api.nvim_create_autocmd("User", {
              callback = play_sound,
              group = group,
              pattern = v,
            })
          end
        end

        -- Are any events left?
        if next(events) ~= nil then
          vim.api.nvim_create_autocmd(events, {
            callback = play_sound,
            group = group,
          })
        end
      end
    end
  end

  -- Setup key overrides
  local key_overrides = M.config.options.profiles[M.profile].by_key
  local used_profile = M.profile
  if key_overrides ~= nil then
    local key_to_sound = {}
    for key, sound in pairs(key_overrides) do
      local key_sounds = {}

      if type(sound) == "string" then
        table.insert(key_sounds, M.resolve_sound(sound))
      elseif type(sound) == "table" then
        for _, s in pairs(sound) do
          table.insert(key_sounds, M.resolve_sound(s))
        end
      end
      -- Create new table with keys converted with `nvim_replace_termcodes` and sound path resolved
      key_to_sound =
        vim.tbl_extend("force", key_to_sound, { [vim.api.nvim_replace_termcodes(key, true, true, true)] = key_sounds })
    end
    vim.on_key(function(pressed)
      -- If profile changed, remove the listener by returning nil
      if used_profile ~= M.profile then
        return nil
      end

      if M.active then
        local s = key_to_sound[pressed]
        if s ~= nil then
          M.play(s[math.random(#s)])
        end
      end
    end)
  end
end

return M
