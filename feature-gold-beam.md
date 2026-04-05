# Feature Specification: The "Gold Tether" (Vertical Steal Mechanic)

**Target Platform:** MTA:SA (Multiplayer Theft Auto: San Andreas)
**Language:** Lua (Client & Server) + HLSL (Shader)
**Architecture:** Hybrid (Client-Side Detection + Server-Side Validation)
**Context:** A vehicular "Capture the Gold" game mode. Players are locked in vehicles. The "Carrier" currently holds the gold. The Carrier's "Jump Ability" is already implemented.

## 1. Feature Overview
When the Gold Carrier activates their "Jump Ability," they create a temporary vertical vulnerability zone (the "Gold Tether"). If an opposing player drives directly underneath the airborne Carrier, the gold is instantly transferred to the opponent. This mechanic is active *only* while the Carrier is airborne *from the jump ability*. It is visualized by a dynamic, scrolling "UFO tractor beam" and actual floating 3D gold bar objects cascading down the beam.

## 2. State Management (The Trigger)
* **Variable:** Introduce a globally synced state or element data (e.g., `isCarrierUsingJumpAbility`).
* **Activation:** Set to `true` exactly when the Carrier triggers the jump ability.
* **Deactivation:** Set to `false` the moment the Carrier's vehicle touches the ground (`isVehicleOnGround` returns true), if the Carrier loses the gold, or if the time limit of the ability expires.

## 3. Hitbox Logic: Client-Side Detection & Server Validation
To optimize performance while preventing exploits, the collision math is distributed to the clients but verified by the server.

**Part A: Client-Side Detection (The Chaser)**
1. **Execution:** Run a mathematical check within `onClientRender` or a fast local timer, but *only* execute if `isCarrierUsingJumpAbility == true` and the local player is *not* the Carrier.
2. **The Math:** Calculate the 2D distance between the local player's vehicle and the Carrier's vehicle using `getDistanceBetweenPoints2D`.
3. **Conditions:** * Is the 2D distance less than or equal to `3.5` units (adjust based on vehicle width)?
    * Is the local player's Z-coordinate *lower* than the Carrier's Z-coordinate?
4. **Action:** If both conditions are met, trigger a server event: `triggerServerEvent("onRequestGoldSteal", localPlayer)`.
5. **Debounce (Crucial):** Implement a client-side cooldown (e.g., 500ms) after triggering this event to prevent flooding the server with requests while rendering at high FPS.

**Part B: Server-Side Validation (The Judge)**
1. **Execution:** Listen for the `"onRequestGoldSteal"` event.
2. **Sanity Checks (Anti-Cheat):**
    * Is `isCarrierUsingJumpAbility` still `true`? (Prevents late requests).
    * Perform a server-side `getDistanceBetweenPoints2D` check between the requester and the Carrier. Allow a slightly larger margin of error for latency (e.g., `<= 5.0` units instead of 3.5).
3. **Action:** If the sanity checks pass, execute the standard "Gold Stolen" function, transferring the gold to the requester, setting `isCarrierUsingJumpAbility = false`, and syncing the new state to all clients.

*Note: Mid-air physical collisions (standard T-bones) should continue to trigger steals via standard `onVehicleCollision` events.*

## 4. Visual Component A: The UFO Power Beam (Shader)
The main beam is visualized using `dxDrawMaterialLine3D` running dynamically every frame via `onClientRender` while `isCarrierUsingJumpAbility == true`.

**Rendering Steps (`onClientRender`):**
1. **Start Point:** Get the Carrier's vehicle position. Offset the Z-coordinate slightly downwards to align with the bottom chassis of the car.
2. **End Point (Ground Detection):** Use `processLineOfSight` shooting straight down from the Start Point (X, Y, StartZ to X, Y, StartZ - 50) to find the exact `hitX, hitY, hitZ` of the terrain/road. Ensure it ignores the Carrier's own vehicle.
3. **Draw the Beam:** Use `dxDrawMaterialLine3D` connecting the Start Point to the hit ground point. 
4. **Width:** Set the line width to roughly match the width of a standard vehicle (e.g., `2.5` or `3.0` units).
5. **Visual:** Apply an HLSL shader to this line. Use the provided high-contrast power beam texture (img/powerbeam.png) as the base map. The shader must rapidly scroll the texture's vertical UV offset downwards based on `gTime`, creating an energy flow illusion. Add glowing 'bloom' effects to enhance visibility.

## 5. Visual Component B: Cascading Gold Objects (Floating Elements)
To provide narrative clarity, small 3D gold bar objects are visually transferred down the beam. This is done with client-side dummy objects (`Object 1212`) created locally for performance.

**Implementation Steps:**
1. **Instantiation:** When `isCarrierUsingJumpAbility` becomes `true`, the local client creates a small pool (e.g., 6–8 total) of "dummy" gold objects (Model 1212).
2. **Critical Setup:** Ensure all objects have `setElementCollisionsEnabled(..., false)`. Optionally apply `setElementAlpha(..., 200)` for slight translucency.
3. **Animation Logic (`onClientRender`):**
    * For each object, track its current local progression (e.g., a value from 0.0 to 1.0, where 0 is the start of the beam and 1 is the ground).
    * Over time, increment this value. Calculate the object's position as a linear interpolation (Lerp) between the current `Start Point` (vehicle) and `End Point` (ground) based on that progression value. 
    * Keep the object aligned with the center of the beam's X and Y axis.
    * Add a slight rotation to make them spin as they fall.
    * When an object's progression hits 1.0 (or its Z-coordinate reaches the ground hit position), immediately reset its progression back to 0.0, restarting it at the vehicle.

## 6. Edge Cases to Handle
* **Water:** If `processLineOfSight` hits water or if the distance to the ground exceeds a massive drop (e.g., > 50 units), the beam should still render but may need an alpha fade-out at the bottom. The gold objects will simply teleport back when they hit the water plane.
* **Race Conditions:** If two clients send `"onRequestGoldSteal"` simultaneously, the server processes them sequentially. Setting `isCarrierUsingJumpAbility = false` upon the first successful validation naturally rejects the second request.
* **Stream-In/Out:** If a chaser drives away from the airborne carrier, the visual elements (beam/objects) must be properly cleaned up and destroyed locally to prevent memory leaks when the carrier is no longer streamed in.