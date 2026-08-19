-- Shedinja Expanded Bridge
--
-- Gold-only compatibility layer. Core Shedinja remains the owner of the
-- species, sprites, animation, encounters, and Wonder Guard. This bridge
-- marks that existing record as an Expanded Species provider record, then
-- restores Shedinja's fixed #292 identity after the framework's generic
-- contiguous allocation pass.

return function(mod)
  local GameVersion = require("src.core.GameVersion")
  if GameVersion.get() ~= "gold" then return {} end

  local SHEDINJA = "SHEDINJA"
  local CORE_MOD = "gen1_shedinja"
  local FRAMEWORK_MOD = "expanded_species"
  local VIRTUAL_INDEX = 292
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

  local core = assert(mod.find(CORE_MOD),
    "Shedinja Expanded Bridge requires the active core Shedinja mod")
  local framework = assert(mod.find(FRAMEWORK_MOD),
    "Shedinja Expanded Bridge requires the active Expanded Species mod")
  assert(core.exports and core.exports.SHEDINJA == SHEDINJA,
    "Shedinja Expanded Bridge could not verify core Shedinja exports")
  assert(framework.exports and type(framework.exports.getApi) == "function",
    "Shedinja Expanded Bridge could not verify the Expanded Species provider API")
  local api = assert(framework.exports.getApi(1),
    "Shedinja Expanded Bridge requires Expanded Species provider API 1")
  assert(type(api.requireCapabilities) == "function", "Expanded Species capability API is unavailable")
  api.requireCapabilities({ "customDex", "safeDefaults" })

  local coreDefinition = assert(mod.content.pokemon:get(SHEDINJA),
    "Shedinja Expanded Bridge must load after the core Shedinja registration")

  -- Expanded Species recognizes custom records through this marker. Its
  -- reconciliation pass will take ownership of the record and keep its save
  -- guardian aware that the defining core mod is active. The bridge repairs
  -- its reserved, official #292 identity immediately after that pass.
  mod.content.pokemon:patch(SHEDINJA, {
    expandedSpecies = {
      api = 1,
      provider = CORE_MOD,
      requestedDex = VIRTUAL_INDEX,
      dexEntry = DEX_ENTRY,
      palette = { normal = NORMAL_PALETTE, shiny = SHINY_PALETTE },
      sourceName = coreDefinition.name or SHEDINJA,
    },
  })

  -- Gold's builtin OLD/National Pokedex order builds a sparse array keyed by
  -- Dex number and traverses it with ipairs. A valid #292 entry would vanish
  -- when there are gaps below it. This wrapper supplies a contiguous order
  -- sorted by entry.dex only for OLD mode; NEW and A-Z retain their normal
  -- engine/framework behavior.
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

  local function copyPalette(row)
    local out = {}
    for index, color in ipairs(row) do
      out[index] = { color[1], color[2], color[3] }
    end
    return out
  end

  local function conflictingSpecies(data)
    for speciesId, definition in pairs((data and data.pokemon) or {}) do
      if speciesId ~= SHEDINJA and type(definition) == "table"
        and definition.index == VIRTUAL_INDEX then
        return speciesId
      end
    end
    return nil
  end

  local function repairAfterFramework(game)
    local data = game and game.data
    local definition = data and data.pokemon and data.pokemon[SHEDINJA]
    if type(definition) ~= "table" then
      mod.log:error("Shedinja Expanded Bridge could not find Shedinja after framework reconciliation")
      return false
    end

    local conflict = conflictingSpecies(data)
    if conflict then
      mod.log:error("Shedinja Expanded Bridge cannot reserve virtual index 292; already owned by %s", conflict)
      return false
    end

    definition.index = VIRTUAL_INDEX
    definition.dex = VIRTUAL_INDEX
    definition.expandedSpecies = definition.expandedSpecies or {}
    definition.expandedSpecies.provider = CORE_MOD
    definition.expandedSpecies.requestedDex = VIRTUAL_INDEX
    definition.expandedSpecies.virtualIndex = VIRTUAL_INDEX

    local dex = data.gen2Pokedex
    if type(dex) == "table" then
      dex.entries = dex.entries or {}
      dex.entries[SHEDINJA] = dex.entries[SHEDINJA] or { id = SHEDINJA }
      local entry = dex.entries[SHEDINJA]
      entry.dex = VIRTUAL_INDEX
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
        mod.log:warn("Shedinja Expanded Bridge could not restore the core Shedinja menu icon")
      end
    end

    mod.log:info("Shedinja Expanded Bridge reserved Gold virtual index and National Dex #292")
    return true
  end

  -- Expanded Species uses its default priority (0) for reconcile; a negative
  -- priority makes this final repair deterministic without relying on load-order
  -- tie behavior between independent providers.
  mod.events:on("game.ready", function(context)
    repairAfterFramework(context and context.game or mod.game)
  end, -100)

  mod.exports.SHEDINJA = SHEDINJA
  mod.exports.virtualIndex = VIRTUAL_INDEX
  mod.exports.repairAfterFramework = repairAfterFramework
  return mod.exports
end
