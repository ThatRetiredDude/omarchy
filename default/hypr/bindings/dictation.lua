local paths = require("default.hypr.paths")

-- Dictation keys are bound only once the chosen backend is installed, so a
-- selected backend that was removed doesn't hold Right Alt (AltGr) or
-- Alt + Space for nothing. Omarchy ships the adapters for its own backends
-- whether they are installed or not, so those also need the backend's own
-- program; any other backend brings its adapter, which is all
-- omarchy-dictation needs.
-- Personal bindings.lua dictation keys use the same check.
function o.dictation_installed()
  local pipe = io.popen("omarchy-default-dictation 2>/dev/null", "r")
  local backend = pipe and pipe:read("*l")
  if pipe then
    pipe:close()
  end
  if not backend or not backend:match("^[%w%-]+$") then
    return false
  end

  local adapter = "omarchy-dictation-" .. backend
  if o.cmd_present(paths.omarchy_path .. "/bin/" .. adapter) then
    return o.cmd_present(backend)
  end
  return o.cmd_present(adapter)
end

if o.dictation_installed() then
  o.bind("ALT + SPACE", "Toggle dictation", "omarchy-dictation toggle")
  -- A modifier's mask changes between its press and release. Match the keysym
  -- independently of that mask; AltGr layouts use a different keysym.
  o.bind_hold("ALT + Alt_R", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop", { ignore_mods = true })
end
