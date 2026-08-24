# Changelog


## 0.2.0 — Native Crystal support

The bridge now supports **native Pokémon Crystal** on Gen1Recomp `0.2.24` and later. Crystal follows the existing Generation 2 Expanded Species decision: it is inert without Expanded Species and preserves Shedinja’s framework-owned #292 identity, Pokédex entry, normal/shiny palette, party icon, and sparse OLD/National ordering when that optional framework is active.

The native Gen 2 installer has been renamed from Gold-specific terminology to `installGen2Expanded`. Dedicated Crystal entry and full Expanded Species regressions verify the Crystal engine identifier, standalone Gen 2 route, #292 repair, visual restoration, Pokédex ordering, and the fact that native Crystal never activates the separate **Gen 1 Crystal 251** path. No Crystal ROM data or assets are included.

## 0.1.5 — Silver support

The unified bridge now recognizes **Pokémon Silver** as Generation 2. Silver therefore follows the same intended Gen 2 decision as Gold: it remains inert when Expanded Species is absent and uses the Expanded Species #292 identity, palette, icon, and sparse Pokédex repair when that optional framework is active. It no longer incorrectly enters the Gen 1 Crystal 251 path.

This is a direct root-cause correction using Gen1Recomp’s shared `GameVersion.generation()` contract, rather than a separate Silver compatibility layer. A dedicated Silver routing harness and the complete bridge suite pass.

## 0.1.4 — Corrected core package identity

The bridge now requires core **`shedinja` 0.3.0+**, replacing the misspelled `shedninja` package ID. Its own stable bridge ID remains `shedinja_expanded_bridge`. This metadata-only migration keeps the Gold Expanded Species and Gen 1 Crystal 251 bridge behaviors unchanged while restoring correct loader ordering for the renamed core package.

## 0.1.3 — Unified compatibility bridge

The bridge now supports both of Shedinja’s framework compatibility paths in one mod. In **Gold**, it remains an optional Expanded Species integration that restores framework-aware #292 identity, palette, party icon, and sparse OLD/National Pokédex ordering. In **Red, Blue, and Yellow**, it optionally detects Crystal 251, moves Shedinja to Crystal-safe index 252, preserves visible #292, and supplies Crystal split-stat plus genderless metadata.

Core Shedinja is the only hard dependency. Expanded Species and Crystal 251 are now separately optional and game-scoped, so the bridge remains inert on ordinary standalone installations. This retires the need for a separate Crystal 251-specific Shedinja bridge.

## 0.1.2 — Shedinja package identity migration

This release updates the Gold-only bridge to require the renamed **Shedinja 0.2.0+** package identity rather than the retired `gen1_shedinja` identifier. Expanded Species integration, virtual #292 repair, palette restoration, party icon restoration, and sparse Pokédex ordering are otherwise unchanged.

## 0.1.1 — Current-API dependency declarations

Validated against Gen1Recomp **0.2.10**. The bridge now declares explicit repository-hinted hard dependencies on **Expanded Species** and **Shedinja 0.1.10 or later**, allowing the launcher to identify the exact required public repositories. The bridge remains Gold-only and does not load unless both required mods are present and active.

## 0.1.0

This initial Gold-only release adds an explicit compatibility bridge for core Shedinja and Expanded Species. It declares both required dependencies, marks Shedinja as an active framework-owned custom record, reserves Shedinja’s runtime and visible number at **#292**, restores its normal/shiny palette and party icon after framework visual setup, and supplies a localized sparse-National-Dex ordering wrapper so #292 remains visible in Gold’s OLD list.
