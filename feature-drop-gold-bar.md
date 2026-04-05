# Feature Specification: Tactical "Heavy Anchor" Gold Drop

## 1. Overview
This feature implements a tactical "drop" mechanic for a vehicular Capture the Gold game mode in MTA:SA. When the current Gold Carrier presses a specific key (`G`), they instantly drop the gold. 

Mechanically, the gold pickup hitbox spawns instantly on the ground directly beneath the dropping vehicle, allowing for immediate interception. Visually, a custom gold object (model ID 1212) animates falling from the vehicle's release height down to the ground over a 1-second duration.

## 2. Technical Constraints & Architecture
* **Environment:** MTA:SA (Server & Client Lua).
* **Map Geometry:** Because the server lacks 3D map collision data, ground coordinate calculations (`getGroundPosition`) must be performed client-side.
* **Existing Logic:** The server already uses a function named `spawnGoldAtTransform(x, y, groundZ)` which creates the physical hit marker and the visual gold object. This function must be modified to support a "delayed visual" state.

## 3. Step-by-Step Execution Flow

### Step 1: Client-Side Input & Calculation
* Bind a client-side key (`G`) to trigger the drop logic. Ensure this only triggers if the local player is the current Gold Carrier.
* Upon key press, retrieve the vehicle's current 3D coordinates: `startX, startY, startZ`.
* Use `getGroundPosition(startX, startY, startZ)` to determine `groundZ`.
* Trigger a custom server event (e.g., `onPlayerDropGold`) and pass these four arguments: `startX`, `startY`, `startZ`, and `groundZ`.

### Step 2: Server-Side Physical Spawn & Visual Modification
* Listen for the `onPlayerDropGold` event.
* **Modify `spawnGoldAtTransform`:** Update the existing `spawnGoldAtTransform` function to accept an optional boolean parameter, `hideVisual`. 
    * If `hideVisual` is `true`, the function should spawn the physical hit marker/ColShape as normal, but set the standard visual object's alpha to `0` (or `setElementDimension` to an unused dimension) so it is invisible.
* Call the updated `spawnGoldAtTransform(startX, startY, groundZ, true)` so the hit marker is instantly active on the ground, but the permanent visual is hidden.

### Step 3: Server-Side Falling Animation (The Dummy Object)
* Create a temporary "dummy" object (Model ID 1212) exactly at the release coordinates: `startX, startY, startZ`.
* Use `moveObject` to move this dummy object down to `startX, startY, groundZ` over a duration of `1000` milliseconds.

### Step 4: Resolution (Interception vs. Landing)
The server must handle two distinct outcomes for the 1000ms fall duration:

**Outcome A: The Gold is Intercepted (Hit before landing)**
* The existing marker hit-detection logic fires (a player drives into the invisible ground marker).
* **Action Required:** The server must instantly `destroyElement` the falling dummy object. Ensure the standard visual inside the hit marker remains hidden or is destroyed as per your existing pickup logic.

**Outcome B: The Gold Lands (1000ms elapses without a hit)**
* Use a `setTimer` for 1000ms, matching the `moveObject` duration.
* **Action Required:** When the timer concludes, check if the physical ground marker still exists (i.e., it wasn't picked up). If it exists:
    1. Destroy the temporary falling dummy object.
    2. Reveal the standard visual object tied to `spawnGoldAtTransform` (e.g., set its alpha back to `255`).

## 4. Requirements for the AI Developer
* Write the client-side code to handle the keybind, coordinate retrieval, and server event triggering.
* Write the server-side event handler to manage the dummy object creation, the `moveObject` animation, and the 1000ms timer.
* Provide the updated version of `spawnGoldAtTransform` showing how the `hideVisual` parameter is implemented.
* Ensure all elements (dummy objects, timers) are properly cleaned up to prevent memory leaks, especially when an interception cancels the landing timer.