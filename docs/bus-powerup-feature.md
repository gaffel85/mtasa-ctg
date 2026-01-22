# Bus Powerup Feature

## Overview

Provide a "bus powerup" that rewards players who are trailing by a configurable score gap. When an eligible player activates the powerup (press `B`), all other players' vehicles are transformed into buses for a configurable duration (default 10s). While a player is a bus, their vehicle-type powerups (sports/offroad/plane) are disabled. The server is authoritative for eligibility, activation and vehicle transformations.

## Goals

- Give trailing players a tactical comeback tool similar to the existing catch-up hint.
- Keep all authority server-side and ensure powerup interactions are well-defined.
- Make behavior configurable and testable.

## Configuration

- `bus.enabled` (bool) — enable/disable the feature.
- `bus.score_gap` (int) — minimum points behind leader to be eligible (e.g. 10).
- `bus.duration` (seconds) — how long the bus effect lasts (default 10).
- `bus.vehicle_id` (string/int) — model id or name used as the bus vehicle.
- `bus.notify_interval` (seconds) — how often to remind eligible player.
- `bus.cooldown` (seconds, optional) — cooldown between uses per player.

Place these in the server configuration file or `ctg.edf` configuration area.

## Eligibility & Activation

- Server computes leader score periodically (on server tick or score update). If `leader_score - player_score >= bus.score_gap`, mark the player eligible and notify them.
- Server sends an eligibility event to the client which shows a UI hint: "Press B to turn everyone into buses".
- Client binds `B` to a request event `requestUseBusPowerup`. When pressed, client sends the request to the server.
- Server validates the request (still eligible, not on cooldown) and either rejects or runs the bus effect.

## Effect & Data Model

- When activated, server records:
  - `activator` (player who used the powerup)
  - `expiresAt` (timestamp)
  - For each affected player: store `originalVehicleData` (model, health, velocity, rotation, attachments) and set `isBus = true`.
- Server replaces each affected player's vehicle with the configured `bus.vehicle_id`, attempting to preserve driver seat, velocity and facing.
- While `isBus == true`, any attempt to apply sports/offroad/plane powerups must be denied or queued.
- After `duration` expires, server restores each player's original vehicle (or reissues appropriate vehicle spawn) and clears `isBus` and stored state.

## Interactions with Existing Powerups

- Hook into the powerup application path and check `isBus` before allowing sports/offroad/plane transformations.
- If a player had a vehicle-change powerup already applied at the moment they became a bus, suspend that change (store it) and restore after bus ends.
- The activator's own powerups may remain unaffected (unless you prefer otherwise); explicitly document the chosen behavior.

## Server / Client Responsibilities

- Server:
  - Periodic eligibility checks.
  - Validate and execute `requestUseBusPowerup`.
  - Apply vehicle transformations, timers, reversion and cleanup.
  - Block/queue conflicting powerups for `isBus` players.
- Client:
  - Render eligibility hint and activation UI.
  - Bind `B` key to send activation request.
  - Display countdowns/messages for when bus effect is active (driven by server events).

## Events / API (suggested)

- Server → Client: `busEligibilityChanged(player, eligible)` — show/hide hint.
- Client → Server: `requestUseBusPowerup()` — user pressed `B`.
- Server → Client: `busActivated(byPlayer, duration)` — notify players that bus effect started.
- Server → Client: `busExpired(byPlayer)` — notify effect ended.
- Internal: `canApplyVehiclePowerup(player, type)` — check `isBus` and return false if blocked.

## Edge Cases & Notes

- If an affected vehicle is destroyed during the effect, ensure the restore path handles respawns correctly.
- If a player disconnects while `isBus`, clear stored original state to avoid memory leaks.
- If the activator loses eligibility during the active effect (leader changes), do not prematurely cancel the active effect — treat activations as atomic by duration.
- Prevent re-activation while effect active or until cooldown has elapsed.

## Security

- Treat all client messages as requests only; all eligibility and transformations must be validated and executed server-side.

## Testing

- Manual test checklist:
  - Player becomes eligible when behind by `score_gap`.
  - Client displays hint and `B` binding works.
  - Server rejects activation when not eligible.
  - On activation, all other players become buses for `duration` seconds.
  - While bus, vehicle-type powerups fail or are suspended.
  - After expiry, original vehicles / powerups are restored.
  - Disconnects, respawns, and vehicle destruction handled gracefully.

- Automated tests (where possible):
  - Unit test eligibility logic.
  - Integration test for activation path and timer expiry.

## Acceptance Criteria

- Trailing players are correctly detected and notified.
- Activation requires server validation and affects all other players' vehicles for configured duration.
- Other vehicle-type powerups are blocked for duration and restored after expiry.
- No server crashes or persistent state leaks on disconnects/respawns.

## Implementation Tasks (detailed)

1. Add configuration options to server config (`bus.*`).
2. Implement server-side eligibility detection (periodic tick or on score updates).
3. Send eligibility events to clients and add client-side hint & `B` binding.
4. Add server handler for `requestUseBusPowerup` with validation and cooldown logic.
5. Implement transformation utilities: save original vehicle state, replace with bus model, and mark `isBus`.
6. Hook into existing powerup application logic to block/suspend vehicle-type powerups when `isBus` is true.
7. Implement timer and expiry logic to restore vehicles and resume suspended powerups.
8. Add cleanup handlers for disconnects and respawns.
9. Integrate with `shared/powers.repo.lua` or the repo managing powerups.
10. Add tests and update documentation (`README.md` or dedicated docs).

For suggested file locations to modify or add:

- server powerup manager: server/powers.controller.lua or server/power.pickup.lua
- shared powerup repo: shared/powers.repo.lua
- server main/tick: ctg.server.main.lua or similar
- client hint & binding: a new client script (e.g. client/bus_powerup.client.lua) or extend client/help.gui.lua

---

End of feature file.
