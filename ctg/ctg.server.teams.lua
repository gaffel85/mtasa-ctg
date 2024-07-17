local teamsActivated = false

local team1 = {
    members = {},
    score = 0
}
local team2 = {
    members = {},
    score = 0
}

function removeFromPreviousTeam(player)
    removeFromTable(team1.members, getPlayerName(player))
    removeFromTable(team2.members, getPlayerName(player))
end

function updateTeamsActiviated() {
    if (#team1.members == 0 || #team2.members = 0) then
        teamsAcitvated = false
    else 
        teamsAcitvated = true
    end
}

function switchToTeam(team)
    removeFromPreviousTeam(player)
    table.insert(team.members, getPlayerName(player))
    updateTeamsActiviated()
end

function onGoldDelivered(goldCarrier, score)
    local carrierTeam
	if contains(team1.members, goldCarrier) then
        carrierTeam = team1
    else
        carrierTeam = team2
    end

    carrierTeam.score = carrierTeam.score + score
end
addEventHandler("goldDelivered", root, onGoldDelivered)

function switchToTeam1(player)
    switchToTeam(team1)
end
bindKey(bombHolder, "F1", "down", switchToTeam1)

function switchToTeam2(player)
    switchToTeam(team2)
end
bindKey(bombHolder, "F2", "down", switchToTeam1)
