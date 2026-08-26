# Shedinja Compatibility Bridge

**Shedinja Compatibility Bridge** is the single optional companion for the core [Shedinja](https://github.com/inmento/Shedinja) mod. It detects the active game and supported framework, then activates only the compatibility repair that applies. It is safe to leave enabled with core Shedinja even when neither supported framework is installed.

| Active game and framework | Bridge behavior |
|---|---|
| Red, Blue, or Yellow with no Crystal 251 | The bridge is inert; standalone Shedinja remains at its standard internal slot 152 and visible National Dex #292. |
| Red, Blue, or Yellow with Crystal 251 | The bridge moves Shedinja to Crystal-safe internal index 252, preserves visible #292, supplies genderless metadata, and adds Shedinja’s split stats to Crystal 251’s live runtime table. |
| Gold, Silver, or native Crystal with no Expanded Species | The bridge is inert; standalone Shedinja retains its normal Gen 2 behavior. |
| Gold, Silver, or native Crystal with Expanded Species | The bridge preserves Shedinja’s framework-aware virtual/runtime identity and visible National Dex #292, restores its palette and menu icon, and fixes sparse OLD/National Pokédex ordering. |

## Installation

Core Shedinja is the bridge’s only hard requirement. Install it once, then enable this bridge only if you want one of the optional framework paths below.

| Configuration | Also install and enable |
|---|---|
| Crystal 251 in Red, Blue, or Yellow | [Crystal 251](https://github.com/Deftones565/gen1recomp-mod-crystal-251) 0.11.3+ and a completed Crystal 251 ROM import. |
| Expanded Species in Gold, Silver, or native Crystal | [Expanded Species](https://github.com/mistermiracle3036/Expanded-Species) 0.6.5+. |

The bridge does **not** make either external framework mandatory. It does not load Gen 2 framework code in Red, Blue, or Yellow, and it does not load the Gen 1 Crystal 251 path in Gold, Silver, or native Pokémon Crystal. Native Crystal support requires Gen1Recomp `0.2.24` or later and bundles no Crystal ROM data or assets.

## Safety behavior

The native Gen 2 Expanded Species path refuses to use virtual index 292 if another active framework record already owns it. The separate Gen 1 Crystal 251 path refuses to use index 252 if another active Gen 1 record already owns it. Those guards prevent two species from silently sharing a runtime identity.

> **Save caution:** Crystal 251 uses internal index 252 for Shedinja, while standalone R/B/Y uses index 152. Do not move a save containing Shedinja between those two configurations without moving Shedinja out of party and PC first.

## Attribution

This bridge contains no copied Pokémon artwork. It reuses assets registered by core Shedinja. See the core project’s `CREDITS.md` for BouncingPiplup and nuukiie / Nuuk attribution and licensing details.

## License

Unless a file or third-party notice says otherwise, this repository's original source code, configuration, tests, and documentation are licensed under the [MIT License](LICENSE). Read [LICENSE_SCOPE.md](LICENSE_SCOPE.md) for attribution guidance and third-party, asset, user-supplied-source, and game-IP boundaries.
