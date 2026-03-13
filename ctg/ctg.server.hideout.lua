local hideouts

function setHideouts(spawns)
    hideouts = spawns
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
        --exlude other team's hideout from hideouts
        local filteredHideouts = {}
        for i, h in ipairs(hideouts) do
            if h ~= otherTeamsHideout.edl then
                table.insert(filteredHideouts, h)
            end
        end
        hideout = positionCloseTo(filteredHideouts, sourcePos, distanceFromMean, otherTeamsHideout.pos, 300, 0.4)
    else
        local distanceFromMean = getConst().hideoutSpawnDistance
        hideout = chooseRandomCloseToByLimits(hideouts, sourcePos , distanceFromMean, getConst().goldSpawnSafeDistance, getConst().goldSpawnMinDistance)
    end
    local posX, posY, posZ = coordsFromEdl(hideout)

    return setTeamHideout(team, hideout, { x = posX, y = posY, z = posZ }, createMarker(posX, posY, posZ, "checkpoint", 2.0, 255, 0, 0), getElementData(hideout, "desc"))
end

function spawnNewHideout()
    local teams = getTeams()
    if getTeamHideout(teams[1]) then
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
            setTeamHideoutObj(teams[i], hideout)
        end
    end
    refreshAllBlips()
end

function removeOldHideout()
    local teams = getTeams()
    for i, team in ipairs(teams) do
        local hideout = getTeamHideout(team)
        if hideout and hideout.marker then
            if (isElement(hideout.marker)) then
                destroyElement(hideout.marker)
            end
        end
        setTeamHideoutObj(team, nil)
    end
    refreshAllBlips()
end

function markerHit(markerHit, matchingDimension)
    local player = source
    if player == getGoldCarrier() then
        local team = getCtgTeam(player)
        local hideout = getTeamHideout(team)
        if hideout and hideout.marker and markerHit == hideout.marker then
            --removeOldHideout()
            goldDelivered(player)
        end
    end
end
addEventHandler("onPlayerMarkerHit", getRootElement(), markerHit)
