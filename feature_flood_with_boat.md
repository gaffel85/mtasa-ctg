# Feature: Flood with Boat (Amphibious)

## Overview
A power-up that combines the existing "Flood" effect with a dynamic vehicle transformation. It raises the sea level under the player and temporarily transforms their vehicle into a boat if they become submerged.

## Mechanics

### 1. Activation
- When the power is activated, a patch of water (radius ~1000m) is created at the player's current location.
- The water level rises to approximately 2 meters below the player's altitude at the moment of activation.
- The power has a set duration (e.g., 15 seconds), after which the water level gradually drains.

### 2. Dynamic Transformation (Amphibious Mode)
- **Submersion Check:** While the power is active, the system periodically checks the altitude of the player's vehicle relative to the current (raised) water level.
- **Boat Switch:** If the vehicle's position falls below the water surface, it is instantly transformed into a boat (e.g., **Speeder**, ID 452).
- **Land Reversion:** If the vehicle moves out of the water or the water drains such that the vehicle is no longer submerged, it reverts to the current round's default vehicle.
- **Scope:** This transformation only affects the player who activated the power. Other players caught in the flood remain in their original vehicles (and are likely stuck/slowed by the water).

### 3. Deactivation & Cleanup
- Once the power duration expires, the water level drains to its original state.
- The player's vehicle is reverted to the standard round vehicle if it was still in boat form.
- The player is protected from drowning while the power is active.

## Technical Considerations
- Reuse `raiseWaterEffect` logic from `water.power.lua`.
- Implement a timer-based check (e.g., every 500ms) during the power's `IN_USE` state to handle the `setVehicleForPlayer` calls.
- Ensure the boat transformation preserves vehicle health and team colors (handled by `setVehicleForPlayer`).
- The Gold Bar must remain attached if the Gold Carrier uses this power (if allowed).
