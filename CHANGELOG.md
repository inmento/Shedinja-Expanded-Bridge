# Changelog

## 0.1.3 — Unified compatibility bridge

The bridge now supports both of Shedinja’s framework compatibility paths in one mod. In **Gold**, it remains an optional Expanded Species integration that restores framework-aware #292 identity, palette, party icon, and sparse OLD/National Pokédex ordering. In **Red, Blue, and Yellow**, it optionally detects Crystal 251, moves Shedinja to Crystal-safe index 252, preserves visible #292, and supplies Crystal split-stat plus genderless metadata.

Core Shedinja is the only hard dependency. Expanded Species and Crystal 251 are now separately optional and game-scoped, so the bridge remains inert on ordinary standalone installations. This retires the need for a separate Crystal 251-specific Shedinja bridge.

## 0.1.2 — Shedinja package identity migration

This release updates the Gold-only bridge to require the renamed **Shedinja 0.2.0+** package identity rather than the retired `gen1_shedinja` identifier. Expanded Species integration, virtual #292 repair, palette restoration, party icon restoration, and sparse Pokédex ordering are otherwise unchanged.

## 0.1.1 — Current-API dependency declarations

Validated against Gen1Recomp **0.2.10**. The bridge now declares explicit repository-hinted hard dependencies on **Expanded Species** and **Shedinja 0.1.10 or later**, allowing the launcher to identify the exact required public repositories. The bridge remains Gold-only and does not load unless both required mods are present and active.

## 0.1.0

This initial Gold-only release adds an explicit compatibility bridge for core Shedinja and Expanded Species. It declares both required dependencies, marks Shedinja as an active framework-owned custom record, reserves Shedinja’s runtime and visible number at **#292**, restores its normal/shiny palette and party icon after framework visual setup, and supplies a localized sparse-National-Dex ordering wrapper so #292 remains visible in Gold’s OLD list.
