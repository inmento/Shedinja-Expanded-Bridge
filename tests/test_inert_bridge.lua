local callbacks = { events = {} }

package.preload["src.core.GameVersion"] = function()
  return { get = function() return "yellow" end }
end

local core = { exports = { SHEDINJA = "SHEDINJA" } }
local mod = {
  id = "shedinja_expanded_bridge",
  find = function(first, second)
    local id = second or first
    if id == "shedninja" then return core end
    return nil
  end,
  content = {
    pokemon = {
      get = function() return { id = "SHEDINJA", index = 152, dex = 292 } end,
      each = function() return function() return nil end end,
      patch = function() error("inert bridge must not patch Gen 1 without Crystal 251") end,
    },
    constants = { patch = function() error("inert bridge must not patch constants without Crystal 251") end },
  },
  events = {
    on = function(_, name) callbacks.events[name] = true end,
  },
  exports = {},
  log = { info = function() end, warn = function() end, error = function() end },
}

local bridge = assert(loadfile("main.lua"))()(mod)
assert(bridge.mode == "standalone_gen1",
  "bridge must remain inert on ordinary Gen 1 installs without Crystal 251")
assert(bridge.repairAfterFramework == nil and bridge.repairAfterCrystal == nil,
  "inert bridge must not expose inactive repair paths")
assert(next(callbacks.events) == nil,
  "inert bridge must not add lifecycle hooks")

print("Shedinja Compatibility Bridge inert harness: valid")
