local root = arg[1] or "."
package.path = "/home/ubuntu/reference_gen1recomp0210_source/?.lua;/home/ubuntu/reference_gen1recomp0210_source/?/init.lua;" .. package.path

local Manifest = require("src.mods.Manifest")
local raw = {
  id = "shedinja_expanded_bridge",
  name = "Shedinja Expanded Bridge",
  version = "0.1.2",
  api = 2,
  entry = "main.lua",
  profile = "content",
  category = "COMPATIBILITY",
  permissions = { "engine_internals" },
  games = { "gen2" },
  game_version = ">=0.2.3 <1.0.0",
  affects_link = true,
  dependencies = {
    {
      id = "expanded_species",
      range = ">=0.6.5 <2.0.0",
      github = "mistermiracle3036/Expanded-Species",
    },
    {
      id = "shedninja",
      range = ">=0.2.0 <1.0.0",
      github = "inmento/Gen1-Shedinja",
    },
  },
  description = "Gold-only Shedinja and Expanded Species compatibility bridge.",
}

local manifest = Manifest.validate(raw, root)
assert(manifest.id == "shedinja_expanded_bridge")
assert(manifest.gen2compat == true and not manifest.gen1compat,
  "bridge manifest must target Gold only")
assert(#manifest.dependencySpecs == 2, "bridge must declare both required mods")
assert(manifest.dependencySpecs[1].id == "expanded_species"
  and manifest.dependencySpecs[1].github == "mistermiracle3036/Expanded-Species"
  and manifest.dependencySpecs[2].id == "shedninja"
  and manifest.dependencySpecs[2].github == "inmento/Gen1-Shedinja",
  "bridge dependency IDs or repository sources changed unexpectedly")
print("bridge v0.2.10 engine manifest test passed")
