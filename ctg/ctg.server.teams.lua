local teamsActivated = false

local team1 = {
    members = {},
    team = nil,
    score = 0,
    scoreLabel = nil,
    textDisplay = nil,
    otherTeam = nil
}
local team2 = {
    members = {},
    team = nil,
    score = 0,
    scoreLabel = nil,
    textDisplay = nil,
    otherTeam = nil
}

local teamsScoreDisplay

local team1Display
local team2Display

function setup()
    team1.otherTeam = team2
    team2.otherTeam = team1
    team1.team = createTeam("Team 1", 100, 100, 255)
    team2.team = createTeam("Team 2", 100, 255, 100)

    teamsScoreDisplay = textCreateDisplay ()
    local r1,g1,b1 = getTeamColor(team1.team)
    local r2,g2,b2 = getTeamColor(team2.team)
    team1HeaderText = textCreateTextItem ( "Team1", 0.3, 0.05, "medium", r1, g1, b1, 255, 2, "right", "top", 128) 
    textDisplayAddText ( teamsScoreDisplay, team1HeaderText )
    team2HeaderText = textCreateTextItem ( "Team1", 0.6, 0.05, "medium", r2, g2, b2, 255, 2, "left", "top", 128) 
    textDisplayAddText ( teamsScoreDisplay, team2HeaderText )

    team1.scoreLabel = textCreateTextItem ( "0", 0.3, 0.15, "medium", r1, g1, b1, 255, 2, "right", "top", 128)
    team2.scoreLabel = textCreateTextItem ( "0", 0.6, 0.15, "medium", r2, g2, b2, 255, 2, "right", "top", 128)
    textDisplayAddText ( teamsScoreDisplay, team1.scoreLabel )
    textDisplayAddText ( teamsScoreDisplay, team2.scoreLabel )

    team1.textDisplay = textCreateDisplay()
    local team1YourTeamText = textCreateTextItem ( "Your team", 0.3, 0.1, "medium", r1, g1, b1, 255, 1, "right", "top", 128) 
    local team1SwitchText = textCreateTextItem ( "Press [F2] to join", 0.6, 0.1, "medium", r2, g2, b2, 255, 0.8, "left", "top", 128) 
    textDisplayAddText ( team1.textDisplay, team1YourTeamText )
    textDisplayAddText ( team1.textDisplay, team1SwitchText )

    team2.textDisplay = textCreateDisplay()
    local team2YourTeamText = textCreateTextItem ( "Your team", 0.6, 0.1, "medium", r2, g2, b2, 255, 1, "left", "top", 128) 
    local team2SwitchText = textCreateTextItem ( "Press [F1] to join", 0.3, 0.1, "medium", r1, g1, b1, 255, 0.8, "right", "top", 128) 
    textDisplayAddText ( team2.textDisplay, team2YourTeamText )
    textDisplayAddText ( team2.textDisplay, team2SwitchText )

end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), setup)

function removeFromPreviousTeam(player)
    setPlayerTeam(player, nil)
    removeFromTable(team1.members, getPlayerName(player))
    removeFromTable(team2.members, getPlayerName(player))
end

function updateTeamsActiviated()
    if (#team1.members == 0 or #team2.members == 0) then
        teamsAcitvated = false
    else 
        teamsAcitvated = true
    end
end

function switchToTeam(team, player)
    removeFromPreviousTeam(player)
    textDisplayRemoveObserver(team.otherTeam.textDisplay, player)
    table.insert(team.members, getPlayerName(player))
    setPlayerTeam(player, team.team)
    textDisplayAddObserver(team.textDisplay, player)
    updateTeamsActiviated()
end

function giveTeamScore(player, score)
    local carrierTeam
    local team = getPlayerTeam(player)
	if team1.team == team then
        carrierTeam = team1
    else
        carrierTeam = team2
    end

    carrierTeam.score = carrierTeam.score + score
    updateScoreDisplay()
end

function updateScoreDisplay()
    textItemSetText(team1.scoreLabel, ""..team1.score)
    textItemSetText(team2.scoreLabel, ""..team2.score)
end

function switchToTeam1(player)
    switchToTeam(team1, player)
end

function switchToTeam2(player)
    switchToTeam(team2, player)
end

function bindTheKeys ( )
    bindKey ( source, "F1", "up", switchToTeam1, source )
    bindKey ( source, "F2", "up", switchToTeam2, source ) 
    textDisplayAddObserver ( teamsScoreDisplay, source ) 
end
addEventHandler("onPlayerJoin", getRootElement(), bindTheKeys)

  --unbind on quit
function unbindTheKeys ( )
    unbindKey ( source, "F1" )
    unbindKey ( source, "F2" ) 
    textDisplayRemoveObserver ( teamsScoreDisplay, source )
end
addEventHandler("onPlayerQuit", getRootElement(), unbindTheKeys)
