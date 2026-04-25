# Feature Specification: Team Game Goal

Currently the game has no end. If one gold bar is deliverd a next one is spawned and that continues forever. I want the game to have a clear goal so that the game has an end.

# Idea

If playing with teams there should be a fixed number of  rounds. The team that wins most rounds will win. If a team already has won more then half of the rounds, the game will end.

When a winner can decided (all rounds played or one team won a majority of rounds) the game should present the winning team. After some seconds the a new screen should appear where the game automatically divide players into new teams based on their current score, to create as even teams as possible. Then the game will start fresh with the new teams (but players can keep their individual scores).

# Specifications
- The numbers of rounds for a game should be able to be set in the admin UI (F6).

# Flow

## Start the game
If teams are acitived (one player has chosen a team) all other players will be automatically added to a team (already implemented). That should also trigger a new spawn of the gold (reset the round) (not implemented).

## Rounds
THe rounds and who has won each round should be shown in the UI in some way. Currently the teams, their score and the team members are shown at the top of the screen. Team 1 a bit to the left of the center and team 2 a bit to the right. 

The rounds works as usual. PLayers fetch the gold and delivers is and the team gets points when delivered, but now they should also get round wins. Maybe we don't need score for teams anymore.

## End the game
The the gold is delivered that makes one team win the winning sequence (super slow mo with panning camera) is shown as usual. Then the screen should face out and then fade in with the camera in a fixed preset location. The scene should contain two levels, like a bridge or a roof where the winners and their vehicles can be placed (inlcuding name tag on the vehicle if that's not already on by default), and the losers on the level below. It should not be possible to control the cars or move the camera for the players. The winners should be able to use use the jump power (RMB) like in the winners can do in Rocket League.  There should be some disgrading things happen to the losers, like their car explodes or similiar. Try to come up with more ideas.

After 10seconds the screen should fade out to black. While black new teams should be assigned. Team1 and Team2 should be on each half of the screen. One player name at the time appears in the middle of the screen and glides over to the assigned team based on their score. It should look a bit random. WHen all players has been assigned to a team, the screen fades in to each players random spawned car. The team scores should be reset but the player score can be kept.