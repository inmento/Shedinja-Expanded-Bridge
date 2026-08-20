package.preload["src.core.GameVersion"] = function()
  return {
    get = function() return "silver" end,
    generation = function(id)
      assert(id == "silver", "bridge must classify the active Silver version")
      return 2
    end,
  }
end

local core = { exports = { SHEDINJA = "SHEDINJA" } }
local mod = {
  id = "shedinja_expanded_bridge",
  find = function(first, second)
    local id = second or first
    if id == "shedinja" then return core end
    if id == "CRYSTAL_251" then
      error("Silver must not request the Gen 1 Crystal 251 compatibility path")
    end
    return nil
  end,
  exports = {},
  log = { info = function() end, warn = function() end, error = function() end },
}

local bridge = assert(loadfile("main.lua"))()(mod)
assert(bridge.mode == "standalone_gen2",
  "Silver without Expanded Species must use the inert Gen 2 bridge mode")
assert(bridge.repairAfterFramework == nil and bridge.repairAfterCrystal == nil,
  "Silver standalone mode must not expose inactive framework or Crystal repair paths")
assert(bridge.SHEDINJA == "SHEDINJA" and bridge.virtualIndex == 292,
  "Silver bridge must retain the core Shedinja bridge metadata")

print("Shedinja Compatibility Bridge Silver routing harness: valid")
