local root = arg[1] or "."
package.path = "/home/ubuntu/reference_gen1recomp023_source/?.lua;/home/ubuntu/reference_gen1recomp023_source/?/init.lua;" .. package.path

local Manifest = require("src.mods.Manifest")
local raw = {
  id = "shedinja_expanded_bridge",
  name = "Shedinja Expanded Bridge",
  version = "0.1.0",
  api = 2,
  entry = "main.lua",
  profile = "content",
  category = "COMPATIBILITY",
  permissions = { "engine_internals" },
  games = { "gen2" },
  game_version = ">=0.2.3 <1.0.0",
  affects_link = true,
  dependencies = {
    "expanded_species@>=0.6.5 <2.0.0",
    "gen1_shedinja@>=0.1.7 <1.0.0",
  },
  description = "Gold-only Shedinja and Expanded Species compatibility bridge.",
}

local manifest = Manifest.validate(raw, root)
assert(manifest.id == "shedinja_expanded_bridge")
assert(manifest.gen2compat == true and not manifest.gen1compat,
  "bridge manifest must target Gold only")
assert(#manifest.dependencySpecs == 2, "bridge must declare both required mods")
assert(manifest.dependencySpecs[1].id == "expanded_species"
  and manifest.dependencySpecs[2].id == "gen1_shedinja",
  "bridge dependency IDs changed unexpectedly")
print("bridge engine manifest test passed")
