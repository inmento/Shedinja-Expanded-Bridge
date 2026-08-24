-- Shedinja Compatibility Bridge
--
-- One optional companion for core Shedinja. The bridge is deliberately inert
-- unless the active game's supported roster framework is present:
--   * Gen 2 + Expanded Species: preserve Shedinja's framework-owned #292 slot.
--   * R/B/Y + Crystal 251: move Shedinja from Crystal's occupied slot 152 to
--     Crystal-safe slot 252, retaining National Dex #292 and Crystal metadata.
--
-- Future compatibility paths belong in their own game/framework installer below
-- instead of adding more standalone bridge mods.

return function(mod)
  local GameVersion = require("src.core.GameVersion")

  local SHEDINJA = "SHEDINJA"
  local CORE_MOD = "shedinja"
  local EXPANDED_MOD = "expanded_species"
  local CRYSTAL_MOD = "CRYSTAL_251"
  local NATIONAL_DEX = 292
  local CRYSTAL_SAFE_INDEX = 252
  local ICON_ID = "ICON_GEN1_SHEDINJA"

  local NORMAL_PALETTE = {
    { 255, 255, 255 }, { 214, 165, 41 }, { 115, 90, 58 }, { 0, 0, 0 },
  }
  local SHINY_PALETTE = {
    { 255, 255, 255 }, { 230, 173, 115 }, { 107, 82, 74 }, { 0, 0, 0 },
  }
  local DEX_ENTRY = {
    kind = "SHED POKEMON",
    height = 207,
    weight = 26,
    text = "HOLLOW BUG SHELL.<NEXT>LEGEND SAYS IT<NEXT>STEALS THE SPIRIT",
    text2 = "OF THOSE WHO PEEK.<NEXT>IT NEVER EATS<NEXT>OR BREATHES.",
  }
  local CRYSTAL_BASE_STATS = {
    hp = 1,
    attack = 90,
    defense = 45,
    speed = 40,
    specialAttack = 30,
    specialDefense = 30,
  }

  local core = assert(mod.find(CORE_MOD),
    "Shedinja Compatibility Bridge requires the active core Shedinja mod")
  assert(core.exports and core.exports.SHEDINJA == SHEDINJA,
    "Shedinja Compatibility Bridge could not verify core Shedinja exports")

  local function copyPalette(row)
    local out = {}
    for index, color in ipairs(row) do out[index] = { color[1], color[2], color[3] } end
    return out
  end

  local function copyCrystalStats()
    return {
      hp = CRYSTAL_BASE_STATS.hp,
      attack = CRYSTAL_BASE_STATS.attack,
      defense = CRYSTAL_BASE_STATS.defense,
      speed = CRYSTAL_BASE_STATS.speed,
      specialAttack = CRYSTAL_BASE_STATS.specialAttack,
      specialDefense = CRYSTAL_BASE_STATS.specialDefense,
    }
  end

  local function installGen2Expanded()
    local framework = mod.find(EXPANDED_MOD)
    if not framework then return nil end
    assert(framework.exports and type(framework.exports.getApi) == "function",
      "Shedinja Compatibility Bridge could not verify the Expanded Species provider API")
    local api = assert(framework.exports.getApi(1),
      "Shedinja Compatibility Bridge requires Expanded Species provider API 1")
    assert(type(api.requireCapabilities) == "function",
      "Expanded Species capability API is unavailable")
    api.requireCapabilities({ "customDex", "safeDefaults" })

    local coreDefinition = assert(mod.content.pokemon:get(SHEDINJA),
      "Shedinja Compatibility Bridge must load after core Shedinja registration")

    mod.content.pokemon:patch(SHEDINJA, {
      expandedSpecies = {
        api = 1,
        provider = CORE_MOD,
        requestedDex = NATIONAL_DEX,
        dexEntry = DEX_ENTRY,
        palette = { normal = NORMAL_PALETTE, shiny = SHINY_PALETTE },
        sourceName = coreDefinition.name or SHEDINJA,
      },
    })

    -- The Gen 2 builtin OLD/National Pokedex traverses sparse numeric entries with
    -- ipairs. This wrapper supplies a complete sorted order only for OLD mode.
    local BasePokedex = require("src.ui.gen2.PokedexMenu")
    mod.content.screens:register("Gen2PokedexMenu", {
      new = function(game, opts)
        local screen = BasePokedex.new(game, opts)
        local baseOrder = screen.order
        function screen:order()
          if self:mode() ~= "OLD" then return baseOrder(self) end
          local rows = {}
          for species, entry in pairs((self.dex and self.dex.entries) or {}) do
            if type(entry) == "table" and type(entry.dex) == "number"
              and self.pokemon and self.pokemon[species] then
              rows[#rows + 1] = { species = species, dex = entry.dex }
            end
          end
          table.sort(rows, function(left, right)
            if left.dex ~= right.dex then return left.dex < right.dex end
            return left.species < right.species
          end)
          local ordered = {}
          for _, row in ipairs(rows) do ordered[#ordered + 1] = row.species end
          return ordered
        end
        return screen
      end,
    })

    local function conflictingSpecies(data)
      for speciesId, definition in pairs((data and data.pokemon) or {}) do
        if speciesId ~= SHEDINJA and type(definition) == "table"
          and definition.index == NATIONAL_DEX then
          return speciesId
        end
      end
      return nil
    end

    local function repairAfterFramework(game)
      local data = game and game.data
      local definition = data and data.pokemon and data.pokemon[SHEDINJA]
      if type(definition) ~= "table" then
        mod.log:error("Shedinja Compatibility Bridge could not find Shedinja after Expanded Species reconciliation")
        return false
      end

      local conflict = conflictingSpecies(data)
      if conflict then
        mod.log:error("Shedinja Compatibility Bridge cannot reserve virtual index 292; already owned by %s", conflict)
        return false
      end

      definition.index = NATIONAL_DEX
      definition.dex = NATIONAL_DEX
      definition.expandedSpecies = definition.expandedSpecies or {}
      definition.expandedSpecies.provider = CORE_MOD
      definition.expandedSpecies.requestedDex = NATIONAL_DEX
      definition.expandedSpecies.virtualIndex = NATIONAL_DEX

      local dex = data.gen2Pokedex
      if type(dex) == "table" then
        dex.entries = dex.entries or {}
        dex.entries[SHEDINJA] = dex.entries[SHEDINJA] or { id = SHEDINJA }
        local entry = dex.entries[SHEDINJA]
        entry.dex = NATIONAL_DEX
        for key, value in pairs(DEX_ENTRY) do entry[key] = value end
      end

      local palettes = data.gen2Palettes
      if type(palettes) == "table" then
        palettes.pokemon = palettes.pokemon or {}
        palettes.pokemon[SHEDINJA] = {
          normal = copyPalette(NORMAL_PALETTE),
          shiny = copyPalette(SHINY_PALETTE),
        }
      end

      local icons = data.gen2Icons
      if type(icons) == "table" then
        icons.species = icons.species or {}
        if icons.icons and icons.icons[ICON_ID] then
          icons.species[SHEDINJA] = ICON_ID
        else
          mod.log:warn("Shedinja Compatibility Bridge could not restore the core Shedinja menu icon")
        end
      end

      return true
    end

    mod.events:on("game.ready", function(context)
      repairAfterFramework(context and context.game or mod.game)
    end, -100)
    return repairAfterFramework
  end

  local function installCrystal251()
    local crystal = mod.find(CRYSTAL_MOD)
    if not crystal then return nil end
    local crystalBaseStats = assert(crystal.exports and crystal.exports.crystalBaseStats,
      "Crystal 251 data is not ready; import its required Crystal ROM and restart")
    assert(type(crystalBaseStats) == "table",
      "Crystal 251 did not expose its runtime base-stat table")

    local function conflictingSpecies(pokemon)
      for id, definition in pairs(pokemon or {}) do
        if id ~= SHEDINJA and type(definition) == "table"
          and definition.index == CRYSTAL_SAFE_INDEX then
          return id
        end
      end
      return nil
    end

    local function applyDefinition(definition)
      definition.index = CRYSTAL_SAFE_INDEX
      definition.dex = NATIONAL_DEX
      -- Crystal 251's gender adapter needs an explicit genderless ratio.
      definition.crystalGenderRatio = 255
      crystalBaseStats[SHEDINJA] = copyCrystalStats()
    end

    local coreDefinition = assert(mod.content.pokemon:get(SHEDINJA),
      "Shedinja Compatibility Bridge must load after core Shedinja registration")
    local startupPokemon = {}
    for id, definition in mod.content.pokemon:each() do startupPokemon[id] = definition end
    assert(not conflictingSpecies(startupPokemon),
      "Shedinja Compatibility Bridge found an occupied Crystal-safe index")

    -- Crystal 251 owns 1–251, including standalone Shedinja's original Gen 1
    -- index 152. Reserve the first free slot and retain visible #292.
    mod.content.constants:patch("dexSize", NATIONAL_DEX)
    mod.content.pokemon:patch(SHEDINJA, {
      index = CRYSTAL_SAFE_INDEX,
      dex = NATIONAL_DEX,
      crystalGenderRatio = 255,
    })
    crystalBaseStats[SHEDINJA] = copyCrystalStats()

    local function repairAfterCrystal(game)
      local data = game and game.data
      local pokemon = data and data.pokemon
      local definition = pokemon and pokemon[SHEDINJA]
      if type(definition) ~= "table" then
        mod.log:error("Shedinja Compatibility Bridge could not find Shedinja after Crystal setup")
        return false
      end

      local occupiedBy = conflictingSpecies(pokemon)
      if occupiedBy then
        mod.log:error("Shedinja Compatibility Bridge cannot reserve index %d; already owned by %s",
          CRYSTAL_SAFE_INDEX, occupiedBy)
        return false
      end

      applyDefinition(definition)
      if type(data.constants) == "table" then
        data.constants.dexSize = math.max(tonumber(data.constants.dexSize) or 0, NATIONAL_DEX)
      end
      return true
    end

    mod.events:on("game.ready", function(context)
      repairAfterCrystal(context and context.game or mod.game)
    end, -100)
    return repairAfterCrystal
  end

  local playing = GameVersion.get()
  local repairAfterFramework, repairAfterCrystal, mode
  if GameVersion.generation(playing) == 2 then
    repairAfterFramework = installGen2Expanded()
    mode = repairAfterFramework and "expanded_species" or "standalone_gen2"
  else
    repairAfterCrystal = installCrystal251()
    mode = repairAfterCrystal and "crystal_251" or "standalone_gen1"
  end

  mod.exports.SHEDINJA = SHEDINJA
  mod.exports.mode = mode
  mod.exports.virtualIndex = NATIONAL_DEX
  mod.exports.crystalSafeIndex = CRYSTAL_SAFE_INDEX
  mod.exports.repairAfterFramework = repairAfterFramework
  mod.exports.repairAfterCrystal = repairAfterCrystal
  return mod.exports
end
