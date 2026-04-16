# Feature: Save/Restore Score and Teams

## Goal
To allow administrators to save the current state of the game (player scores, team scores, and team assignments) and restore them after a resource restart or a server crash. This is particularly useful during beta testing when frequent restarts are necessary to fix bugs.

## Requirements
- **Save State:** Captures all relevant game state data:
  - Individual player scores (`Score` element data).
  - Team scores (Team 1 and Team 2).
  - Player team assignments (Who is in Team 1 and who is in Team 2).
  - Total score (`TotalScore` element data on `resourceRoot`).
- **Restore State:** Loads the latest saved state and applies it:
  - Re-assigns players to their teams.
  - Restores individual and team scores.
  - Syncs the total score.
- **Admin Interface:** Two new buttons in the Admin Panel (F6):
  - **Save Score & Teams**: Triggers the save process on the server.
  - **Load Score & Teams**: Triggers the restoration process on the server.
- **Persistence:** The state should be saved to a file on the server (e.g., `gamestate.json`) to persist across resource restarts.

## Implementation Details
### Client-side
- Update `ctg/client/admin_dgs.lua` to include a new "Game State" tab with the "Save" and "Load" buttons.
- Buttons will trigger server-side events `saveGameState` and `loadGameState`.

### Server-side
- Update `ctg/server/admin.control.lua` (or create a new dedicated script) to handle:
  - `saveGameState`: Collects data and writes it to a JSON file.
  - `loadGameState`: Reads the JSON file and applies the data to the current players and teams.
- Integration with `ctg/ctg.server.teams.lua` to access and modify team data.
- Integration with `ctg/data/score.shared.lua` to access and modify score data.
