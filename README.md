# Shedinja Expanded Bridge

**Shedinja Expanded Bridge** is a **Gold-only** compatibility add-on for using the standalone **Shedinja** mod together with **Expanded Species**.

It is intentionally a third mod rather than a required dependency of core Shedinja. Red, Blue, and Yellow never load this bridge and retain Shedinja’s standard standalone behavior. Gold players who do not install the bridge likewise retain core Shedinja’s standard Gold slot and behavior.

## Required mods

Install and enable all three mods in Gold:

| Mod | Required version | Role |
|---|---:|---|
| [Expanded Species](https://github.com/mistermiracle3036/Expanded-Species) | 0.6.5–1.x | Custom-species framework and safe-save support. |
| [Shedinja](https://github.com/inmento/Gen1-Shedinja) | 0.2.0+ | Shedinja’s species data, sprites, animation, encounters, Wonder Guard, and one-HP behavior. |
| Shedinja Expanded Bridge | 0.1.2+ | Framework-aware #292 identity and sparse Pokédex compatibility. |

> Do not enable this bridge without both required mods. The launcher enforces both dependencies.

## What the bridge changes in Gold

Expanded Species normally allocates custom Pokémon sequentially starting at #252. This bridge marks Shedinja as a framework-owned custom species, then reserves both Shedinja’s **virtual internal index** and every player-visible Dex number as **#292** after the framework finishes its normal setup. This lets Shedinja retain its official number while other Expanded Species packs use their own slots.

The bridge also restores Shedinja’s credited core palette and party icon after Expanded Species installs its custom-species visuals. Its Gold Pokédex wrapper fixes the native sparse-number ordering path so valid National Dex entries such as #292 remain visible in the OLD/National list.

## Important limit

The bridge refuses to remap Shedinja if another active custom species already owns virtual index 292. This is a deliberate safety guard: two distinct species must never share one runtime index.

## Attribution

This bridge contains no copied Pokémon artwork. It reuses the assets registered by core Shedinja. See that project’s `CREDITS.md` for the complete BouncingPiplup and nuukiie / Nuuk attribution and license information.
