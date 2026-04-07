# Feature: Respawn on Damage

## Overview
Replaces the old 5-second freeze-and-repair mechanic with a dynamic respawn system that teleports players back to their location from 2 seconds ago when their vehicle is too damaged.

## Mechanics
- **Trigger:** When vehicle health drops below 250 (considered "too damaged").
- **Time Offset:** Players are teleported to where they were 2 seconds before the damage threshold was reached.
- **Sequence:**
  1. Camera fades out for 1 second.
  2. Vehicle is teleported and frozen at the historical location.
  3. Gold bar is dropped at the location of destruction if the player was the Gold Carrier.
  4. Camera fades in.
  5. A 2-second visual countdown is displayed.
  6. Vehicle is released with the velocity and angular velocity it had at that historical moment.
- **Player Feedback:** A message is displayed explaining that the vehicle was too damaged and they are being respawned.

## Benefits
- Reduces frustration from being completely stationary for 5 seconds.
- Keeps the momentum of the game by restoring previous velocity.
- Adds a tactical element where "death" results in a slight time-slip rather than a total stop.
