# Feature Specification: Cinematic Victory Sequences
**Project:** MTA:SA Vehicular Capture the Gold

## 1. Overview
When the "Gold Carrier" successfully drives into their team's hideout checkpoint, the round ends. Instead of immediately resetting the map, a cinematic victory sequence plays for a configurable duration. There are 5 distinct victory sequences. The server will randomly select one of these 5 effects each time a round is won.

All effects share a unified camera system: a **Single Shared Camera** that forces all players on the server to watch the same cinematic event, creating a shared experience.

## 2. Global Configuration & Constraints
* `VICTORY_SEQUENCE_DURATION`: Configurable constant (Default: 5000 ms / 5 seconds). Determines how long the sequence plays before triggering the server-side map/round reset.
* `SINGLE_PLAYER_FALLBACK`: All logic must gracefully handle scenarios where the winner is the only player on the server (e.g., during testing). If no enemies are present, loops evaluating enemies should safely pass, and the camera should default to a tight focus on the winner.
* **UI State:** During the sequence, player HUDs/minimaps should be hidden, but the chat should remain visible for player reactions.

## 3. Dynamic Camera System
Before executing the specific sequence camera behavior, the client must calculate the bounding box or radius of the action.
* **Scan Radius:** Upon victory, scan for all enemy vehicles within a ~50-unit radius of the winning player.
* **Distance Calculation:** If enemies are nearby, pull the camera's starting distance back proportionally to fit the winner and the furthest nearby enemy in the frame.
* **Fallback:** If no enemies are within the radius (or it's a single-player session), default to a standard close-up cinematic distance (e.g., 10-15 units away).

## 4. Victory Sequences (Randomly Selected)

### Option 1: The "Matrix" Freeze
* **Description:** The exact millisecond the winner hits the checkpoint, all momentum in the game completely halts. A shader turns the world black and white, leaving only the winning vehicle and the Gold Bar in full color. The camera smoothly orbits the frozen scene.
* **Implementation Steps:**
    1. Server triggers client event: `setElementFrozen(true)` for all vehicles on the server instantly.
    2. Client applies a screen-source desaturation shader to the world.
    3. Client applies a mask or stencil to exclude the winning vehicle element from the desaturation shader.
    4. Client calculates camera matrix: Starts at ground level looking slightly up at the winner, then interpolates (`interpolateBetween`) to orbit 360 degrees and rise upwards over the `VICTORY_SEQUENCE_DURATION`.

### Option 2: The "Bullet Time" Slow-Mo
* **Description:** Similar to the Matrix freeze, but instead of stopping completely, the game speed drops to an extreme crawl, allowing players to watch near-misses and collisions resolve in super slow motion while the camera orbits.
* **Implementation Steps:**
    1. Server calls `setGameSpeed(0.05)`.
    2. Client utilizes the exact same dynamic 360-degree orbiting camera logic as Option 1.
    3. (Optional) Pitch down the game audio to match the slow-motion effect.
    4. Upon sequence end, reset game speed back to `1.0`.

### Option 3: The Kinetic Shockwave
* **Description:** The winner slams into the checkpoint, detonating a massive physical shockwave that violently blasts all nearby enemy vehicles away. 
* **Implementation Steps:**
    1. Server freezes the winning vehicle on the marker and makes it invulnerable.
    2. Server grabs all opposing vehicles within a large radius.
    3. Server applies `setElementVelocity` to push those enemy vehicles sharply outward and upward, away from the winner's coordinates.
    4. Camera: Shared static camera positioned directly above the winner (Top-Down/Birds-Eye View) to capture the radial blast pushing enemies to the edges of the screen.

### Option 4: The Orbital Strike Sudden Death
* **Description:** The winner is secured. Two seconds later, every enemy vehicle on the map simultaneously detonates.
* **Implementation Steps:**
    1. Server freezes and applies invulnerability to the winning team's vehicles.
    2. Server initiates a 2000 ms timer.
    3. When the timer pops, server calls `blowVehicle` on every enemy vehicle currently active on the map. (If single-player, this step safely does nothing).
    4. Camera: A shared static camera placed extremely high and far back (Stadium Shot) to provide the widest possible Field of View (FOV) of the map, capturing as many synchronized explosions as possible.

### Option 5: The Automated Getaway (Crash)
* **Description:** The winner's steering is disabled, and the gas pedal is jammed down. They speed forward away from the checkpoint uncontrollably while the camera watches from behind.
* **Implementation Steps:**
    1. Server forces control states for the winning ped using `setPedControlState`: enable "accelerate", disable "vehicle_left", "vehicle_right", "brake_reverse".
    2. Server applies invulnerability to the winning vehicle so it doesn't explode upon the inevitable collision.
    3. Camera: Placed slightly behind and above the hideout checkpoint. The camera's position remains static, but its "look at" target dynamically updates every frame to track the winning vehicle as it drives away (Security Camera tracking style).

## 5. Cleanup & Reset Phase
Once the `VICTORY_SEQUENCE_DURATION` timer completes:
1. Re-enable player HUDs.
2. Remove any active shaders (Option 1).
3. Reset game speed to `1.0` (Option 2).
4. Release camera controls back to local players (`setCameraTarget`).
5. Proceed with standard map cleanup, vehicle respawning, and new Gold Bar coordinate generation.