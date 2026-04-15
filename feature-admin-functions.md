# Feature Admin Functions

This feature adds administrative tools to the CTG game to handle unexpected bugs and manage the game state more effectively.

## Proposed Functions

### 1. Player Score Management
*   **Goal:** Allow admins to manually set the score for any player.
*   **UI:** Add an edit box and "Set Score" button in the "Players" tab of the Admin Panel.
*   **Implementation:**
    *   Server event `setPlayerScore(player, score)` that updates `getElementData(player, "Score")` and recalculates total score and percentages.

### 2. Emergency Gold Recovery (Historical Location)
*   **Goal:** If the gold "disappears" or gets stuck due to a bug (e.g., carrier falling out of world), spawn it where the carrier was 10 seconds ago.
*   **UI:** Add "Spawn Gold @ 10s Ago" button in a new "Gold" tab or "Game State" tab.
*   **Implementation:**
    *   Admins trigger a server event.
    *   Server identifies the current or last gold carrier.
    *   Server triggers `reportLastTransformTimeAgo(10000)` on that player's client.
    *   Client reports back the transform.
    *   Server calls `spawnGoldAtTransform` using the reported coordinates.

### 3. Precision Gold Respawn (Closest Spawn)
*   **Goal:** Respawn the gold at the nearest valid `goldSpawnPoint` relative to its current position. Useful if the gold is in an unreachable but known location.
*   **UI:** Add "Respawn Gold (Closest)" button.
*   **Implementation:**
    *   Get current gold position (from `activeGoldObject`).
    *   Iterate through all `goldSpawnPoint` elements in the map.
    *   Find the one with the minimum 3D distance to the gold.
    *   Call `spawnGoldAtTransform` with the closest spawn's coordinates.

### 4. Direct Gold Respawn (Last Spawn)
*   **Goal:** Reset the gold to its original spawn point before it was picked up.
*   **UI:** Add "Respawn Gold (Last)" button.
*   **Implementation:**
    *   Use the stored `lastGoldSpawn` coordinates in `ctg.server.gold.lua`.
    *   Call `spawnGoldAtTransform`.

### 5. Random Nearby Respawn
*   **Goal:** Move the gold to a random tracked player location within 100m. Useful for unsticking gold while keeping it in the same general area.
*   **UI:** Add "Respawn Gold (Random Nearby 100m)" button.
*   **Implementation:**
    *   Get current gold position.
    *   Use `getLocations(x, y, z, 100)` from `location.repo.lua` to find tracked positions.
    *   Pick one at random and call `spawnGoldAtTransform`.

### 6. Player Teleportation
*   **Goal:** Teleport one player to another's current position using the catch-up countdown sequence.
*   **UI:** Destination selection combo box and "Teleport Selected to Destination" button in the Players tab.
*   **Implementation:**
    *   Server event `adminTeleportPlayerToPlayer(targetName, destName)`.
    *   Triggers the client-side `startSuperCatchupSequence` on the target player, passing the destination player as the "leader".

### 7. Fix & Respawn Player
*   **Goal:** Respawn the player at a spawn point and drop their gold if carrier.
*   **UI:** "Fix & Respawn Player" button in the Players tab.
*   **Implementation:**
    *   Server event `adminFixPlayer(playerName)`.
    *   Calls shared `fixPlayer(targetPlayer)` from `ctg.server.main.lua`.

## UI Design (admin_dgs.lua)
*   New **"Gold Control"** tab.
*   Buttons for Gold spawning/respawning.
*   Status indicator for current Gold position/carrier.
*   Enhanced **"Players"** tab with score input, fix/respawn button, and teleportation controls.

## Technical Details
*   **Permissions:** For now, limited to a hardcoded check or basic admin right (to be refined).
*   **Server/Client Communication:** Uses `reportLastTransformTimeAgo` and `reportTransform` for historical recovery.
