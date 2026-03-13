# Project Context: MTA:SA Vehicular Capture the Gold

## Environment & Framework
* **Platform:** MTA:SA (Multiplayer Theft Auto: San Andreas).
* **Format:** Server-side and client-side Lua resource.
* **Game Style:** Team-based, objective-focused vehicular combat.

## Core Rules & Player State
* **Strict Vehicle Confinement:** Players are permanently locked inside their vehicles. On-foot gameplay is completely disabled.

## Game Loop & Mechanics
* **The Objective:** Teams compete to secure a single "Gold Bar" and deliver it to their specific team hideout (checkpoint).
* **Spawning:** The Gold Bar spawns at one of several randomized, predefined coordinates on the map.
* **Acquisition:** The first player to drive their vehicle into the Gold Bar picks it up, becoming the "Gold Carrier."
* **Stealing Mechanic (Tag):** Opposing players can steal the Gold Bar from the current Gold Carrier by physically ramming/hitting the Carrier's vehicle with their own vehicle.
* **Scoring:** To score, the Gold Carrier must successfully navigate to their team's hideout checkpoint without being hit by an opposing vehicle.
