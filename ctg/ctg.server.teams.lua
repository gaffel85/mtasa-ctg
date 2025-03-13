local team1 = {
    members = {},
    team = nil,
    score = 0,
    scoreLabel = nil,
    textDisplay = nil,
    otherTeam = nil,
    hideOut = nil,
    color = {100, 100, 255},
    membersLabel = nil
}
local team2 = {
    members = {},
    team = nil,
    score = 0,
    scoreLabel = nil,
    textDisplay = nil,
    otherTeam = nil,
    hideOut = nil,
    color = {100, 255, 100},
    membersLabel = nil
}

local teamsScoreDisplay

local team1Display
local team2Display

function getTeams()
    return  { team1, team2 }
end

function isTeamsActivated()
    return team1.members and team2.members and #team1.members > 0 and #team2.members > 0
end

function getCtgTeam(player)
    local team = getPlayerTeam(player)
	if team1.team == team then
        return team1
    else
        return team2
    end
end

function getOpponents(player)
    local team = getCtgTeam(player)
    local otherTeam = team.otherTeam.team
    return getPlayersInTeam(otherTeam)
end

function setupTeams()
    team1.otherTeam = team2
    team2.otherTeam = team1
    team1.team = createTeam("Team 1", 100, 100, 255)
    team2.team = createTeam("Team 2", 100, 255, 100)

    teamsScoreDisplay = textCreateDisplay ()
    local r1,g1,b1 = getTeamColor(team1.team)
    local r2,g2,b2 = getTeamColor(team2.team)
    team1HeaderText = textCreateTextItem ( "Team1 [F1]", 0.3, 0.05, "medium", r1, g1, b1, 255, 2, "right", "top", 128) 
    textDisplayAddText ( teamsScoreDisplay, team1HeaderText )
    team2HeaderText = textCreateTextItem ( "Team1 [F2]", 0.6, 0.05, "medium", r2, g2, b2, 255, 2, "left", "top", 128) 
    textDisplayAddText ( teamsScoreDisplay, team2HeaderText )

    team1.scoreLabel = textCreateTextItem ( "0", 0.3, 0.015, "medium", r1, g1, b1, 255, 2, "right", "top", 128)
    team2.scoreLabel = textCreateTextItem ( "0", 0.6, 0.015, "medium", r2, g2, b2, 255, 2, "left", "top", 128)
    textDisplayAddText ( teamsScoreDisplay, team1.scoreLabel )
    textDisplayAddText ( teamsScoreDisplay, team2.scoreLabel )

    team1.membersLabel = textCreateTextItem ( "", 0.3, 0.08, "medium", r1, g1, b1, 255, 1, "right", "top", 128)
    team2.membersLabel = textCreateTextItem ( "", 0.6, 0.08, "medium", r2, g2, b2, 255, 1, "left", "top", 128)
    textDisplayAddText ( teamsScoreDisplay, team1.membersLabel )
    textDisplayAddText ( teamsScoreDisplay, team2.membersLabel )

    team1.textDisplay = textCreateDisplay()
    local team1YourTeamText = textCreateTextItem ( "Your team", 0.26, 0.08, "medium", 235, 146, 52, 255, 1, "right", "top", 128) 
    local team1SwitchText = textCreateTextItem ( "Press [F2] to join", 0.6, 0.1, "medium", r2, g2, b2, 255, 0.8, "left", "top", 128) 
    textDisplayAddText ( team1.textDisplay, team1YourTeamText )
    --textDisplayAddText ( team1.textDisplay, team1SwitchText )

    team2.textDisplay = textCreateDisplay()
    local team2YourTeamText = textCreateTextItem ( "Your team", 0.64, 0.08, "medium", 235, 146, 52, 255, 1, "left", "top", 128) 
    local team2SwitchText = textCreateTextItem ( "Press [F1] to join", 0.3, 0.1, "medium", r1, g1, b1, 255, 0.8, "right", "top", 128) 
    textDisplayAddText ( team2.textDisplay, team2YourTeamText )
    --textDisplayAddText ( team2.textDisplay, team2SwitchText )

    for k, player in ipairs(getElementsByType("player")) do
        bindTeamKeysForPlayer(player)
    end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), setupTeams)

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

function removeFromTeam(player)
    removeFromPreviousTeam(player)
    updateTeamsActiviated()
    updateMembersLabel(team)
    updateMembersLabel(team.otherTeam)
    refreshAllBlips()
end

function switchToTeam(team, player, autoJoinRest)
    removeFromPreviousTeam(player)
    textDisplayRemoveObserver(team.otherTeam.textDisplay, player)
    table.insert(team.members, getPlayerName(player))
    setPlayerTeam(player, team.team)
    textDisplayAddObserver(team.textDisplay, player)
    updateTeamsActiviated()
    updateMembersLabel(team)
    updateMembersLabel(team.otherTeam)
    if autoJoinRest then
        automaticallyJoinTeamForNonTeamMembers()
    end
    refreshAllBlips()
end

function updateMembersLabel(team)
    local membersText = table.concat(team.members, "\n")
    textItemSetText(team.membersLabel, membersText)
end

function automaticallyJoinTeamForNonTeamMembers()
    for k, player in ipairs(getElementsByType("player")) do
        if not getPlayerTeam(player) then
            if #team1.members < #team2.members then
                switchToTeam(team1, player, false)
            elseif #team2.members < #team1.members then
                switchToTeam(team2, player, false)
            else
                -- random team
                if math.random(0, 1) == 0 then
                    switchToTeam(team1, player, false)
                else
                    switchToTeam(team2, player, false)
                end
            end
        end
    end
end

function giveTeamScore(player, score)
    if isTeamsActivated() then
        local carrierTeam = getCtgTeam(player)
        carrierTeam.score = carrierTeam.score + score
        updateScoreDisplay()

        for i, memberName in ipairs(carrierTeam.members) do
            local member = getPlayerFromName(memberName)
            if member then
                givePlayerMoney(member, score)
            end
        end
    
        local opponentTeam = carrierTeam.otherTeam
        for i, memberName in ipairs(opponentTeam.members) do
            local member = getPlayerFromName(memberName)
            if member then
                givePlayerMoney(member, score * getConst().moneyToOpponentsPercentage)
            end
        end
    else
        givePlayerMoney(player, score)
        for i, player in ipairs(getElementsByType("player")) do
            if player ~= player then
                givePlayerMoney(player, score * getConst().moneyToOpponentsPercentage)
            end
        end
    end
end

function updateScoreDisplay()
    textItemSetText(team1.scoreLabel, ""..team1.score)
    textItemSetText(team2.scoreLabel, ""..team2.score)
end

function switchToTeam1(player)
    switchToTeam(team1, player, true)
end

function switchToTeam2(player)
    switchToTeam(team2, player, true)
end

function bindTeamKeysForPlayer(player)
  -- outputServerLog("bind "..inspect(player))
    bindKey ( player, "F1", "up", switchToTeam1, player )
    bindKey ( player, "F2", "up", switchToTeam2, player ) 
    textDisplayAddObserver ( teamsScoreDisplay, player )
end

function unbindTeamKeysForPlayer(player)
  -- outputServerLog("unbind "..inspect(player))
    unbindKey ( player, "F1" )
    unbindKey ( player, "F2" ) 
    textDisplayRemoveObserver ( teamsScoreDisplay, player )
end

function bindTheKeys ( )
  -- outputServerLog("source bind "..inspect(source))
    bindTeamKeysForPlayer(source)
end
addEventHandler("onPlayerJoin", getRootElement(), bindTheKeys)

  --unbind on quit
function unbindTheKeys ( )
  -- outputServerLog("source unbindTheKeys "..inspect(source))
    unbindTeamKeysForPlayer(source)
end
addEventHandler("onPlayerQuit", getRootElement(), unbindTheKeys)
