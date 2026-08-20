local root = arg[1] or "."
package.path = "/home/ubuntu/reference_gen1recomp0210_source/?.lua;/home/ubuntu/reference_gen1recomp0210_source/?/init.lua;" .. package.path

local Manifest = require("src.mods.Manifest")
local ModTargets = require("src.mods.ModTargets")

local raw = {
  id = "shedinja_expanded_bridge",
  name = "Shedinja Compatibility Bridge",
  version = "0.1.3",
  github = "inmento/Shedinja-Expanded-Bridge",
  api = 2,
  entry = "main.lua",
  profile = "content",
  category = "COMPATIBILITY",
  permissions = { "engine_internals" },
  games = { "gen1", "gen2" },
  game_version = ">=0.2.10 <1.0.0",
  affects_link = true,
  dependencies = {
    {
      id = "shedinja",
      range = ">=0.2.0 <1.0.0",
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
assert(manifest.version == "0.1.3")
assert(manifest.github == "inmento/Shedinja-Expanded-Bridge")
assert(manifest.gen2compat == true
  and ModTargets.supports(manifest, "red", 1)
  and ModTargets.supports(manifest, "gold", 2),
  "unified bridge must target both Gen 1 and Gold")
assert(#manifest.dependencySpecs == 1
  and manifest.dependencySpecs[1].id == "shedinja"
  and manifest.dependencySpecs[1].github == "inmento/Shedinja",
  "core Shedinja must remain the bridge's only hard requirement")
assert(#manifest.optionalSpecs == 2,
  "supported external frameworks must remain independently optional")

local expanded, crystal
for _, spec in ipairs(manifest.optionalSpecs) do
  if spec.id == "expanded_species" then expanded = spec end
  if spec.id == "CRYSTAL_251" then crystal = spec end
end
assert(expanded and expanded.github == "mistermiracle3036/Expanded-Species"
  and ModTargets.specApplies(expanded, "gold", 2)
  and not ModTargets.specApplies(expanded, "red", 1),
  "Expanded Species must be an optional Gold-only framework")
assert(crystal and crystal.github == "Deftones565/gen1recomp-mod-crystal-251"
  and ModTargets.specApplies(crystal, "red", 1)
  and not ModTargets.specApplies(crystal, "gold", 2),
  "Crystal 251 must be an optional Gen 1-only framework")

print("unified bridge v0.2.10 engine manifest test passed")
