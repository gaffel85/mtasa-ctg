function refreshAllBlips()
    destroyElementsByType("blip")

    local players = getElementsByType("player")
    for k, player in ipairs(players) do
        local team = getPlayerTeam(player)
        local blip = nil
        if player == getGoldCarrier() then
            blip = createBlipAttachedTo ( player, 0 )
        else
            if not team then
                blip = createBlipAttachedTo(player, 0, 2, 128, 128, 128)
            else 
                local r,g,b = getTeamColor(team)
                blip = createBlipAttachedTo(player, 0, 2, r, g, b)
            end
        end
        setElementVisibleTo(blip, player, false)
    end

    if not getGoldCarrier() then
        local goldSpawnEdl = getLastGoldSpawn()
        if (goldSpawnEdl) then
            local posX, posY, posZ = coordsFromEdl(goldSpawnEdl)
            local goldSpawnBlip = createBlip(posX, posY, posZ, 52)

            local extraBlip = createBlip(posX, posY, posZ, 0, 1, 255, 0, 0, 255, 10)
        end
    else 
        local teams = getTeams()
        local goldCarrierNativeTeam = getPlayerTeam(getGoldCarrier())
        -- loop over teams
        for i, team in ipairs(teams) do
            if team.hideout then
                local posX, posY, posZ = team.hideout.pos.x, team.hideout.pos.y, team.hideout.pos.z
                
                local ownTeamHideoutBlip = createBlip(posX, posY, posZ, 31, 1, 255, 0, 0, 255, 5)
                local otherTeamHideoutBlip = createBlip(posX, posY, posZ, 23, 1, 255, 0, 0, 255, 5)
                setElementVisibleTo(ownTeamHideoutBlip, root, false)
                setElementVisibleTo(otherTeamHideoutBlip, root, false)
                for k, member in ipairs(getPlayersInTeam(team.team)) do
                    setElementVisibleTo(ownTeamHideoutBlip, member, true)    
                end
                for k, member in ipairs(getPlayersInTeam(team.otherTeam.team)) do
                    setElementVisibleTo(otherTeamHideoutBlip, member, true)    
                end

                if (team.team == goldCarrierNativeTeam) then
                    local extraBlip = createBlip(posX, posY, posZ, 0, 2, 255, 0, 0, 255, 10)
                    setElementVisibleTo(extraBlip, root, false)
                    setElementVisibleTo(extraBlip, getGoldCarrier(), true)
                end
            end
        end
    end
end