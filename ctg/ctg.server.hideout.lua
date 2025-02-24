local hideouts

function setHideouts(spawns)
    hideouts = spawns
end

function getTeamHideout(player)
    local team = getCtgTeam(player)
    if (team) then
        return team.hideout
    end
end

function spawnNewHideoutForTeam(team, otherTeamsHideout)
    local sourcePos
    if getGoldCarrier() then
        local x, y, z = getElementPosition(getGoldCarrier())
        sourcePos = { x = x, y = y, z = z }
    else
        sourcePos = meanPositionOfPlayers()
    end

    local hideout
    if otherTeamsHideout then
        local x1, y1, z1 = otherTeamsHideout.pos.x, otherTeamsHideout.pos.y, otherTeamsHideout.pos.z
        local distanceFromMean = getDistanceBetweenPoints3D(x1, y1, z1, sourcePos.x, sourcePos.y, sourcePos.z)
        hideout = positionCloseTo(hideouts, sourcePos, distanceFromMean, otherTeamsHideout.pos, 300, 0.4)
    else
        local distanceFromMean = 800
        hideout = chooseRandomCloseTo(hideouts, sourcePos , distanceFromMean)
    end
    local posX, posY, posZ = coordsFromEdl(hideout)

    team.hideout = {
        edl = hideout,
        pos = { x = posX, y = posY, z = posZ },
        marker = createMarker(posX, posY, posZ, "checkpoint", 2.0, 255, 0, 0)
    }
    return team.hideout
end

function spawnNewHideout()
    local teams = getTeams()
    if teams[1].hideout then
        return
    end
    removeOldHideout()

    -- for each team create a new hideout
    local lastTeamHideout = nil
    if isTeamsActivated() then
        for i, team in ipairs(teams) do
            lastTeamHideout = spawnNewHideoutForTeam(team, lastTeamHideout)
        end
    else
        local hideout = spawnNewHideoutForTeam(teams[1])
        --for the rest of the teams, use the same hideout
        for i = 2, #teams do
            teams[i].hideout = hideout
        end
    end
    refreshAllBlips()
end

function removeOldHideout()
    local teams = getTeams()
    if not isTeamsActivated() then
        local team = teams[1]
        if team.hideout and team.hideout.marker then
            destroyElement(team.hideout.marker)
        end
        team.hideout = nil
        team.otherTeam.hideout = nil
        return
    end

    for i, team in ipairs(teams) do
        if team.hideout and team.hideout.marker then
            destroyElement(team.hideout.marker)
        end
        team.hideout = nil
    end
    refreshAllBlips()
end

function markerHit(markerHit, matchingDimension)
    local player = source
    if player == getGoldCarrier() then
        local team = getCtgTeam(player)
        if markerHit == team.hideout.marker then
            removeOldHideout()
            goldDelivered(player)
        end
    end
end
addEventHandler("onPlayerMarkerHit", getRootElement(), markerHit)
