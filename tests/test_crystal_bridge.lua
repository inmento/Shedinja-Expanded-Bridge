local callbacks = { events = {} }

package.preload["src.core.GameVersion"] = function()
  return {
    get = function() return "crystal" end,
    generation = function(id) return id == "crystal" and 2 or 1 end,
    engine = function(id) return id == "crystal" and "crystal" or "gen1" end,
  }
end

package.preload["src.ui.gen2.PokedexMenu"] = function()
  return {
    new = function(game, opts)
      opts = opts or {}
      local screen = {
        game = game,
        dex = opts.pokedex or game.data.gen2Pokedex,
        pokemon = opts.pokemon or game.data.pokemon,
        modeValue = "OLD",
      }
      function screen:mode() return self.modeValue end
      function screen:order() return { "PIKACHU" } end
      return screen
    end,
  }
end

local pokemon = {
  SHEDINJA = {
    id = "SHEDINJA", name = "SHEDINJA", index = 252, dex = 292,
    spriteFront = "/core/assets/gen2/shedinja_front_1.png",
    spriteBack = "/core/assets/gen2/shedinja_back.png",
  },
  PIKACHU = { id = "PIKACHU", name = "PIKACHU", index = 25, dex = 25 },
}
local screenRecords = {}
local framework = {
  exports = {
    getApi = function(version)
      assert(version == 1, "bridge must negotiate Expanded Species API 1")
      return {
        requireCapabilities = function(names)
          assert(names[1] == "customDex" and names[2] == "safeDefaults",
            "bridge must request the framework's stable baseline capabilities")
          return true
        end,
      }
    end,
  },
}
local core = { exports = { SHEDINJA = "SHEDINJA" } }
local game = {
  data = {
    pokemon = pokemon,
    gen2Pokedex = { entries = { PIKACHU = { id = "PIKACHU", dex = 25 } } },
    gen2Palettes = { pokemon = { SHEDINJA = { normal = { {1, 1, 1} } } } },
    gen2Icons = {
      icons = { ICON_GEN1_SHEDINJA = { image = "/core/assets/gen2/shedinja_icon.png" } },
      species = { SHEDINJA = "ICON_DITTO" },
    },
  },
}

local mod = {
  id = "shedinja_expanded_bridge",
  game = game,
  find = function(first, second)
    local id = second or first
    if id == "shedinja" then return core end
    if id == "expanded_species" then return framework end
    return nil
  end,
  content = {
    pokemon = {
      get = function(_, id) return pokemon[id] end,
      patch = function(_, id, partial)
        for key, value in pairs(partial) do pokemon[id][key] = value end
      end,
    },
    screens = {
      register = function(_, id, value) screenRecords[id] = value end,
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
assert(bridge.mode == "expanded_species",
  "unified bridge must select its Crystal Expanded Species path when that framework is active")
assert(bridge.repairAfterCrystal == nil,
  "Native Crystal must not install the Gen 1 Crystal 251 repair path")
assert(pokemon.SHEDINJA.expandedSpecies
  and pokemon.SHEDINJA.expandedSpecies.provider == "shedinja"
  and pokemon.SHEDINJA.expandedSpecies.requestedDex == 292,
  "bridge must mark core Shedinja as an Expanded Species provider record")
assert(type(screenRecords.Gen2PokedexMenu) == "table",
  "bridge must register the localized Crystal Pokedex screen wrapper")
assert(callbacks.events["game.ready"] and callbacks.events["game.ready"].priority == -100,
  "bridge must repair Shedinja after the framework's default-priority reconciliation")

-- Simulate Expanded Species' generic contiguous allocation and visual fallback.
pokemon.SHEDINJA.index, pokemon.SHEDINJA.dex = 252, 252
game.data.gen2Pokedex.entries.SHEDINJA = { id = "SHEDINJA", dex = 252 }
game.data.gen2Palettes.pokemon.SHEDINJA = { normal = { { 8, 8, 8 } } }
game.data.gen2Icons.species.SHEDINJA = "ICON_DITTO"
callbacks.events["game.ready"].callback({ game = game })

local shedinja = pokemon.SHEDINJA
assert(shedinja.index == 292 and shedinja.dex == 292,
  "bridge must reserve both Shedinja virtual index and displayed Dex number at #292")
assert(shedinja.expandedSpecies.virtualIndex == 292,
  "bridge must mark the fixed virtual index for diagnostics")
local entry = game.data.gen2Pokedex.entries.SHEDINJA
assert(entry.dex == 292 and entry.kind == "SHED POKEMON"
  and entry.height == 207 and entry.weight == 26,
  "bridge must restore Shedinja's complete #292 Dex entry")
assert(game.data.gen2Palettes.pokemon.SHEDINJA.normal[2][1] == 214
  and game.data.gen2Palettes.pokemon.SHEDINJA.shiny[2][1] == 230,
  "bridge must restore core Shedinja normal and shiny palettes")
assert(game.data.gen2Icons.species.SHEDINJA == "ICON_GEN1_SHEDINJA",
  "bridge must restore core Shedinja's party icon after framework visuals")

local screen = screenRecords.Gen2PokedexMenu.new(game)
local order = screen:order()
assert(#order == 2 and order[1] == "PIKACHU" and order[2] == "SHEDINJA",
  "bridge must expose sparse #292 Shedinja in Crystal's OLD/National Pokedex order")
screen.modeValue = "NEW"
assert(screen:order()[1] == "PIKACHU", "bridge must preserve non-OLD Pokedex modes")

pokemon.OTHER = { id = "OTHER", name = "OTHER", index = 292, dex = 293 }
pokemon.SHEDINJA.index, pokemon.SHEDINJA.dex = 252, 252
assert(bridge.repairAfterFramework(game) == false,
  "bridge must refuse a conflicting virtual index rather than silently colliding")
assert(pokemon.SHEDINJA.index == 252 and pokemon.SHEDINJA.dex == 252,
  "bridge must leave a conflicting allocation untouched")

print("Shedinja Expanded Bridge integration harness: valid")
