# Feature: Respawn on Death (Rewind)

## Overview
Replaces standard spawn-point-based death respawning with a dynamic "rewind" system that teleports players back to their location from 2 seconds ago when they die or manually repair.

## Mechanics
- **Trigger:** 
  - When the player dies (`onClientPlayerWasted`).
  - When the player manually repairs/flips using the 'R' key.
- **Time Offset:** Players are teleported to where they were 2 seconds before the trigger.
- **Sequence:**
  1. Camera fades out for 1 second.
  2. Vehicle is teleported and frozen at the historical location.
  3. Gold bar is dropped at the location of destruction if the player was the Gold Carrier.
  4. Player is resurrected and warped back into the vehicle if they were dead.
  5. Camera fades in.
  6. A 2-second visual countdown is displayed.
  7. Vehicle is released with the velocity and angular velocity it had at that historical moment.
- **Upside-down Detection:** 
  - If the vehicle is detected to be upside-down (on its roof), a visual prompt "Press 'R' to flip your vehicle!" is displayed.
- **Standard Death Skip:** The server-side standard respawn logic is skipped if a rewind is in progress to prevent double spawning.

## Benefits
- Keeps the momentum of the game by restoring previous velocity after a crash or flip.
- Reduces frustration from being sent to a distant spawn point after a minor mistake.
- Interactive feedback for flipping cars makes the mechanic more discoverable.
