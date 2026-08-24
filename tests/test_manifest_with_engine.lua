local root = arg[1] or "."
package.path = "/tmp/gen1recomp-current-crystal/?.lua;/tmp/gen1recomp-current-crystal/?/init.lua;" .. package.path

local Manifest = require("src.mods.Manifest")
local ModTargets = require("src.mods.ModTargets")
local Semver = require("src.mods.Semver")

local raw = {
  id = "shedinja_expanded_bridge",
  name = "Shedinja Compatibility Bridge",
  version = "0.2.0",
  github = "inmento/Shedinja-Expanded-Bridge",
  api = 2,
  entry = "main.lua",
  profile = "content",
  category = "COMPATIBILITY",
  permissions = { "engine_internals" },
  games = { "gen1", "gen2" },
  game_version = ">=0.2.24 <1.0.0",
  affects_link = true,
  dependencies = {
    {
      id = "shedinja",
      range = ">=0.3.0 <1.0.0",
      github = "inmento/Shedinja",
    },
  },
  optional_dependencies = {
    {
      id = "expanded_species",
      range = ">=0.6.5 <2.0.0",
      github = "mistermiracle3036/Expanded-Species",
      games = { "gen2" },
    },
    {
      id = "CRYSTAL_251",
      range = ">=0.11.3 <1.0.0",
      github = "Deftones565/gen1recomp-mod-crystal-251",
      games = { "gen1" },
    },
  },
  description = "Unified Shedinja compatibility bridge.",
}

local manifest = Manifest.validate(raw, root)
assert(manifest.id == "shedinja_expanded_bridge")
assert(manifest.version == "0.2.0")
assert(manifest.github == "inmento/Shedinja-Expanded-Bridge")
assert(manifest.gen2compat == true
  and ModTargets.supports(manifest, "red", 1)
  and ModTargets.supports(manifest, "gold", 2)
  and ModTargets.supports(manifest, "silver", 2)
  and ModTargets.supports(manifest, "crystal", 2),
  "unified bridge must target Gen 1 plus Gold, Silver, and Crystal")
assert(#manifest.dependencySpecs == 1
  and manifest.dependencySpecs[1].id == "shedinja"
  and manifest.dependencySpecs[1].github == "inmento/Shedinja",
  "core Shedinja must remain the bridge's only hard requirement")
assert(Semver.satisfies("0.3.4", manifest.dependencySpecs[1].range)
  and Semver.satisfies("0.3.6", manifest.dependencySpecs[1].range),
  "the core range must accept established Shedinja 0.3.x releases")
assert(#manifest.optionalSpecs == 2,
  "supported external frameworks must remain independently optional")

local expanded, crystal
for _, spec in ipairs(manifest.optionalSpecs) do
  if spec.id == "expanded_species" then expanded = spec end
  if spec.id == "CRYSTAL_251" then crystal = spec end
end
assert(expanded and expanded.github == "mistermiracle3036/Expanded-Species"
  and ModTargets.specApplies(expanded, "gold", 2)
  and ModTargets.specApplies(expanded, "silver", 2)
  and ModTargets.specApplies(expanded, "crystal", 2)
  and not ModTargets.specApplies(expanded, "red", 1),
  "Expanded Species must be an optional native Gen 2 framework")
assert(crystal and crystal.github == "Deftones565/gen1recomp-mod-crystal-251"
  and ModTargets.specApplies(crystal, "red", 1)
  and not ModTargets.specApplies(crystal, "gold", 2)
  and not ModTargets.specApplies(crystal, "crystal", 2),
  "Crystal 251 must remain an optional Gen 1-only framework")

print("unified bridge engine manifest and core-version-range test passed")
