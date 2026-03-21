# Feature: Temporary Power-ups (Consumable)

## Overview
A Mario Kart-style consumable power-up system where players can obtain, queue, and use one-time effects. Unlike the resource-based power system, these are removed from the player's inventory upon use.

## Technical Architecture

### 1. Shared Configuration (`ctg/shared/temp_powers_config.lua`)
- **Registry:** `TemporaryPowerups` table stores all registered power-ups.
- **Registration:** `registerTemporaryPower(id, config)` adds a new power-up.
- **Metadata Sync:** Automatically synchronizes power-up metadata (name, description, icon, duration) to clients.
- **Evaluation:** Evaluates `duration` and `description` (supporting both `desc` and `description` fields) to ensure consistency between server-side function-based configs and client-side UI requirements.

### 2. Server-Side Management (`ctg/server/temp_power_manager.lua`)
- **Queue System:**
  - Tracks a queue for each player (max size: 2).
  - `giveRandomTemporaryPowerup(player)`: Adds a random power to the queue.
  - `useTemporaryPowerup(player)`: Activates the first power in the queue.
- **Lifecycle Management:**
  - **Activation:** Calls `powerConfig.onActivated(player, vehicle, state)`.
  - **Global Lock:** Prevents multiple temporary powers from being active simultaneously across the server.
  - **Automatic Deactivation:** Uses a server-side timer to call `powerConfig.onDeactivated(player, vehicle, state)` once the `duration` expires.
- **Synchronization:**
  - Syncs the player's queue and any globally active effects to clients.
  - Handles cleanup when players join, quit, or the resource restarts.

### 3. Client-Side Implementation
- **Input (`ctg/client/temp_power_input.lua`):**
  - Binds the **"X"** key to trigger `onUseTemporaryPowerupServer`.
- **UI (`ctg/client/temp_power_ui.lua`):**
  - Displays the current queue using a "card" interface.
  - Shows progress bars for all active temporary power-up effects on the server.
  - Visual feedback for the "locked" state when another power is active.

## Power-up Configuration Schema
Temporary powers use the same interface as the resource-based power system:

```lua
local myPower = {
    key = "unique_key",
    name = "Power Name",
    desc = "Short description for UI", -- or 'description'
    iconPath = "img/icon.png",
    duration = function() return 10 end, -- can be a number or function returning a number
    onActivated = function(player, vehicle, state)
        -- Start effect
    end,
    onDeactivated = function(player, vehicle, state)
        -- Cleanup effect
    end
}

registerTemporaryPower("my_power_id", myPower)
```

## Current State
- [x] 1. Shared registry and metadata sync.
- [x] 2. Consumable queue logic (2 slots).
- [x] 3. Global activation locking.
- [x] 4. Automatic cleanup via `onDeactivated`.
- [x] 5. DGS-based UI with progress bars.
- [x] 6. Integration with existing power definitions (Cinematic Camera, Bustrip, etc.).
- [x] 7. Show warning to opponents before effect is activated 
- [ ] 8. Logic for obtaining powers (e.g., pickups or event triggers).

## Tasks

### 7. Show warning to opponents before effect is activated 
When a player presses X to activate a power, instead of a direct effect, all opponents will be warned 3 seconds before with a countdown that the effect will soon take effect. 

#### UI
Above the active power UI show a text telling the players that what kind of power that will soon be active. Above the text a alert icon (img/alert.png) should flash. The warning should be removed when the effect starts.
