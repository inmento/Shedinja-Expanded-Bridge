local callbacks = { events = {} }

package.preload["src.core.GameVersion"] = function()
  return { get = function() return "red" end }
end

local pokemon = {
  SHEDINJA = {
    id = "SHEDINJA", name = "SHEDINJA", index = 152, dex = 292,
    baseStats = { hp = 1, attack = 90, defense = 45, speed = 40, special = 30 },
  },
  CHIKORITA = { id = "CHIKORITA", name = "CHIKORITA", index = 152, dex = 152 },
  CELEBI = { id = "CELEBI", name = "CELEBI", index = 251, dex = 251 },
}
local constants = { dexSize = 251 }
local crystalBaseStats = {
  CHIKORITA = {
    hp = 45, attack = 49, defense = 65, speed = 45,
    specialAttack = 49, specialDefense = 65,
  },
}
local core = { exports = { SHEDINJA = "SHEDINJA" } }
local crystal = { exports = { crystalBaseStats = crystalBaseStats } }
local game = { data = { pokemon = pokemon, constants = constants } }

local function eachPokemon()
  local ids = {}
  for id in pairs(pokemon) do ids[#ids + 1] = id end
  table.sort(ids)
  local i = 0
  return function()
    i = i + 1
    local id = ids[i]
    if id then return id, pokemon[id] end
  end
end

local mod = {
  id = "shedinja_expanded_bridge",
  game = game,
  find = function(first, second)
    local id = second or first
    if id == "shedninja" then return core end
    if id == "CRYSTAL_251" then return crystal end
    return nil
  end,
  content = {
    constants = {
      patch = function(_, key, value) constants[key] = value end,
    },
    pokemon = {
      get = function(_, id) return pokemon[id] end,
      each = function() return eachPokemon() end,
      patch = function(_, id, partial)
        for key, value in pairs(partial) do pokemon[id][key] = value end
      end,
    },
  },
  events = {
    on = function(_, name, callback, priority)
      callbacks.events[name] = { callback = callback, priority = priority }
    end,
  },
  exports = {},
  log = { info = function() end, warn = function() end, error = function() end },
}

local bridge = assert(loadfile("main.lua"))()(mod)
assert(bridge.mode == "crystal_251",
  "unified bridge must select its Crystal 251 path in Red, Blue, and Yellow")
assert(bridge.repairAfterFramework == nil,
  "Gen 1 must not install the Gold Expanded Species repair path")
assert(pokemon.SHEDINJA.index == 252 and pokemon.SHEDINJA.dex == 292,
  "bridge must move Shedinja out of Crystal's index-152 Chikorita slot")
assert(constants.dexSize == 292,
  "bridge must restore the sparse Shedinja National Dex range after Crystal's #251 setup")
assert(pokemon.SHEDINJA.crystalGenderRatio == 255,
  "bridge must mark Shedinja as genderless for Crystal UI and battle adapters")
local crystalStats = crystalBaseStats.SHEDINJA
assert(crystalStats and crystalStats.hp == 1 and crystalStats.attack == 90
  and crystalStats.defense == 45 and crystalStats.speed == 40
  and crystalStats.specialAttack == 30 and crystalStats.specialDefense == 30,
  "bridge must add Shedinja's split base stats to Crystal's live runtime table")
assert(callbacks.events["game.ready"] and callbacks.events["game.ready"].priority == -100,
  "bridge must retain a late safety repair after Crystal's lifecycle setup")

pokemon.SHEDINJA.index, pokemon.SHEDINJA.dex = 152, 251
constants.dexSize = 251
assert(bridge.repairAfterCrystal(game) == true,
  "bridge must repair Shedinja after a safe later Crystal lifecycle change")
assert(pokemon.SHEDINJA.index == 252 and pokemon.SHEDINJA.dex == 292
  and constants.dexSize == 292,
  "late repair must retain Crystal-safe index 252 and National Dex #292")

pokemon.OTHER = { id = "OTHER", name = "OTHER", index = 252, dex = 293 }
pokemon.SHEDINJA.index, pokemon.SHEDINJA.dex = 152, 251
assert(bridge.repairAfterCrystal(game) == false,
  "bridge must refuse a conflicting Crystal-safe index")
assert(pokemon.SHEDINJA.index == 152 and pokemon.SHEDINJA.dex == 251,
  "bridge must leave a conflicting later allocation untouched")

print("Shedinja Compatibility Bridge Crystal 251 harness: valid")
