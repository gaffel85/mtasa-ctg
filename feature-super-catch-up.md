# Feature: Super Catch-Up

Super Catch-Up is an admin-granted ability designed to help inexperienced players stay in the action. It allows a player to instantly teleport to the leader's position with matching velocity after a short cinematic sequence.

## 1. Admin Management (Admin UI)
- **Access:** A GUI window accessible by pressing **F6** (replacing the old admin UI).
- **Security Check:** For now, access is restricted to players with the name **"Gaffel"**.
- **Technology:** Must be implemented using the **dgs** (Dynamic Graphical System) library.
- **Features:**
    - List all active players in the server.
    - A toggle (Checkbox or Button) for each player to enable/disable their "Super Catch-Up" status.
    - A "Close" button to hide the UI.
- **Persistence:** The power is **permanent** once granted (until the admin toggles it off or the session ends).
- **Sync:** The status must be maintained on the server and synced to the client.

## 2. Activation & Player Experience
- **Trigger:** Player presses **'Z'** (the standard catch-up key).
    - If they have "Super Catch-Up" granted, it **overrides** the standard catch-up behavior.
    - If they do NOT have it, the standard catch-up behavior remains unchanged.
- **Sequence (3-second duration):**
    - **T = 0s (Start):**
        - Screen fades out and back in (`fadeCamera`).
        - Client camera switches to follow the current leader (determined by `findLeader(player)`).
        - A countdown (3, 2, 1) is displayed in the center of the screen.
    - **T = 2s (The Freeze):**
        - The server/client records the leader's current position, rotation, and velocity.
        - The player's vehicle is teleported to this recorded position.
        - Player controls are disabled using `toggleAllControls(false, true, false)` (matching the project's repair logic).
        - The vehicle is set to "Ghost Mode" using the existing `makePlayerGhost(player, seconds, safeCheck, invisible)` function in `ghost.server.lua`.
    - **T = 3s (The Release):**
        - Player controls are restored using `toggleAllControls(true, true, true)`.
        - The vehicle's velocity is set to the velocity recorded from the leader at T=2s.
        - Ghost Mode remains active until the player's vehicle is no longer overlapping with any other players (handled by `safeCheck = true` in `makePlayerGhost`).

## 3. Integration Details
- **Leader Detection:** Utilize existing `findLeader(player)` logic which identifies the Gold Carrier or the player closest to the gold.
- **Ghosting:** Use `makePlayerGhost(player, 1, true, false)` at T=2s. The `safeCheck = true` ensures it stays ghosted until the area is clear.
- **Freezing:** Mirror the "paralyze" logic found in `ctg/ctg.client.collision.lua`.
- **Velocity Handling:** Use `getElementVelocity` to capture leader state and `setElementVelocity` to apply it to the player.

## 4. Technical Requirements for AI Agents
- Implement the Admin UI in a new client file (e.g., `ctg/client/super_catchup_admin.lua`) using **dgs**.
- Handle the server-side state of granted powers in a manager (e.g., `ctg/server/super_catchup_manager.lua`).
- Create a new client-side script for the Super Catch-Up sequence to manage the camera, countdown, and local effects.
- Ensure proper cleanup if a player dies, disconnects, or the leader disappears during the 3-second sequence.
