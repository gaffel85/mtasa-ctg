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

function spawnNewHideoutForTeam(team)
    local hideout = hideouts[math.random(#hideouts)]
    local posX, posY, posZ = coordsFromEdl(hideout)

    team.hideout = {
        edl = hideout,
        pos = { x = posX, y = posY, z = posZ },
        marker = createMarker(posX, posY, posZ, "checkpoint", 2.0, 255, 0, 0)
    }
end

function spawnNewHideout()
    removeOldHideout()

    -- for each team create a new hideout
    local teams = getTeams()
    for i, team in ipairs(teams) do
        spawnNewHideoutForTeam(team)
    end
    refreshAllBlips()
end

function removeOldHideout()
    local teams = getTeams()
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
