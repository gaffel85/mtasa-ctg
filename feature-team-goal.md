# Feature Specification: Match System & Post-Game Sequence
**Context:** MTA:SA (Multiplayer Theft Auto: San Andreas). Server-side and client-side Lua resource.
**Game Mode:** Vehicular Capture the Gold. Players are strictly confined to vehicles.

## 1. Global Logic & Round System
* **Configuration:** Add `max_rounds` as a configurable setting in the admin UI (F6).
* **Win Condition:** A team wins the match when they reach a score of `math.floor(max_rounds / 2) + 1`. 
* **Tie-Breaker:** If `max_rounds` is reached and scores are tied (e.g., 2-2 in a Best of 4), trigger a sudden death round. 
    * **Action:** Broadcast a server event to clients to display a prominent UI text alert at the top of the screen: "TIE BREAKER - NEXT DELIVERY WINS!".

## 2. UI Updates (Client-Side)
* **Remove Old Score:** Remove the integer-based team score display.
* **The "Pips" Tracker:** Render graphical "pips" (e.g., small circles or gold bar icons) between the Team 1 (Left) and Team 2 (Right) names using `dxDraw` functions.
    * The total number of pips per team equals the win condition.
    * Empty pips = rounds needed. Filled pips (using team colors) = rounds won.
    * **Animation:** When a team scores, apply a brief scale/pulse animation to their newly filled pip.

## 3. Post-Match Sequence (Server & Client)
**Trigger:** When a team delivers the gold and hits the Win Condition.
**Flow:** Normal slow-mo delivery sequence -> Fade screen to black -> Fade in to Post-Match Scene.
**Locations:** Assume two predefined coordinate variables exist: `POST_MATCH_PODIUM_POS` and `POST_MATCH_PIT_POS`.

### The Winners (Top Level / Podium)
* Teleport winning team vehicles to `POST_MATCH_PODIUM_POS` (spaced out evenly).
* **Controls:** Use `toggleAllControls(player, false, true, false)` to disable native driving/movement. 
    * *Note on Jump:* The vehicle jump is mapped via a custom `bindKey`. Ensure this specific bind remains active and usable during this phase so winners can celebrate.
* **Environment:** Spawn a large, rotating Gold Bar object in the center of the podium. Trigger particle effects (e.g., fireworks or standard MTA flares) around the vehicles.

### The Losers (Bottom Level / Pit)
* Teleport losing team vehicles to `POST_MATCH_PIT_POS`.
* **Controls:** Disable all player controls entirely, and ensure the custom jump `bindKey` is temporarily ignored or disabled for losers.
* **The "Shame" Sequence (Over 10 seconds):**
    * *Seconds 1-4:* Use `setVehiclePanelState` and `setVehicleDoorState` to randomly pop off doors, hoods, and bumpers. Pop vehicle tires.
    * *Seconds 5-8:* Drop vehicle health using `setElementHealth` to < 300 so the engine catches fire and emits black smoke.
    * *Second 9:* Use `blowVehicle` to explode the losers' cars.

## 4. Team Reassignment & Restart (Server & Client)
**Trigger:** 10 seconds after the Post-Match Scene begins.
**Flow:** 1. Fade screen to black. 
2. **Server-Side Rebalance (Snake Draft):** Sort all players descending by their *individual* score. Assign them to teams in a snake pattern (Rank 1 -> Team 1, Rank 2 -> Team 2, Rank 3 -> Team 2, Rank 4 -> Team 1, etc.) to ensure balanced teams.
3. **Client-Side Visuals (During Black Screen):** Draw a vertical line down the screen center. Player names appear in the middle one by one and horizontally slide to their newly assigned team's side of the screen using an easing function (e.g., `OutQuad`).
4. **Restart:** Once the UI animation completes, reset the team round pips to 0, clear the map, spawn players into their new randomized vehicles at normal spawn points, and fade the screen back in. Individual scores are retained.