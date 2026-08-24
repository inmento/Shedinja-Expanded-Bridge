package.preload["src.core.GameVersion"] = function()
  return {
    get = function() return "crystal" end,
    generation = function(id)
      assert(id == "crystal", "bridge must classify the active Crystal version")
      return 2
    end,
    engine = function(id)
      assert(id == "crystal", "bridge must retain Crystal engine identity")
      return "crystal"
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
      error("Native Crystal must not request the Gen 1 Crystal 251 compatibility path")
    end
    return nil
  end,
  exports = {},
  log = { info = function() end, warn = function() end, error = function() end },
}

local bridge = assert(loadfile("main.lua"))()(mod)
assert(bridge.mode == "standalone_gen2",
  "Crystal without Expanded Species must use the inert native Gen 2 bridge mode")
assert(bridge.repairAfterFramework == nil and bridge.repairAfterCrystal == nil,
  "Crystal standalone mode must not expose inactive framework or Gen 1 Crystal 251 repair paths")
assert(bridge.SHEDINJA == "SHEDINJA" and bridge.virtualIndex == 292,
  "Crystal bridge must retain the core Shedinja bridge metadata")

print("Shedinja Compatibility Bridge Crystal entry harness: valid")
