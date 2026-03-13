# MTA:SA Feature Implementation: Momentum-Based Gold Stealing & DGS Warning UX

## Project Context
This is a vehicular "Capture the Gold" game mode for MTA:SA. Players are locked in vehicles. The gold is transferred when an opposing player's vehicle collides with the current Gold Carrier's vehicle.

## Objective
Update the gold stealing mechanic to prevent players from stealing the gold by simply parking and blocking the carrier. Implement a minimum speed requirement for the attacker, along with a client-side 3D-to-2D visual warning using the `dgs` library when the attacker does not meet the speed requirements.

---

## 1. Server-Side Logic: The Steal Mechanics
Modify the existing vehicle collision event that is triggered from `onCollision` in the file `ctg.client.collision.lua` that handles the gold transfer.

### The Rules
Before transferring the gold from the Carrier to the Attacker, the server must calculate the speed of both vehicles in km/h. The transfer should **ONLY** occur if the Attacker meets at least one of the following two conditions at the moment of impact:

* **Rule 1 (Absolute Speed):** The Attacker's speed is strictly greater than 50 km/h.
* **Rule 2 (Relative Speed):** The Attacker's speed is at least 20 km/h faster than the Carrier's speed.

> **Math Note for AI:** To calculate km/h in MTA:SA, get the vehicle's velocity elements (`getElementVelocity`), calculate the vector magnitude ($\sqrt{x^2 + y^2 + z^2}$), and multiply the result by 180.

---

## 2. Client-Side Logic: The Visual Warning (DGS)
Create a new client-side script that uses the `dgs` library to render a warning sign over the Carrier's vehicle for attackers who are moving too slowly.

### Visual Elements
* **Image:** A 2D "forbidden" sign (red circle with a diagonal red line). Assume the image file is located at `ctg/img/forbidden.png`.
* **Text:** "Too low speed" positioned directly below the image.

### Rendering Conditions (`onClientRender`)
The UI should **ONLY** be rendered if **ALL** of the following conditions are met:
1.  **Carrier Exists:** There is currently an active Gold Carrier in the game.
2.  **Not the Carrier:** The local player is **NOT** the Gold Carrier.
3.  **Distance Check:** The distance between the local player's vehicle and the Carrier's vehicle is 50 meters or less. *(Optimize by doing this check first before calculating speeds).*
4.  **Speed Check Fails:** The local player currently fails **BOTH** Rule 1 and Rule 2 (as defined in the server-side logic above).

### Placement & Projection
* The elements must be projected into the 3D world using `dgs` (e.g., `dgsCreate3DInterface` or similar 3D-to-2D screen projection math).
* The position should track the Gold Carrier's vehicle, specifically anchored about 1.5 meters above the vehicle's Z-coordinate to avoid blocking the attacker's line of sight to the carrier's chassis.
* The UI should fade out or disappear immediately if the local player accelerates and satisfies either Rule 1 or Rule 2.