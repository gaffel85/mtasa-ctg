local allBlips = {}

function refreshAllBlips()
    for k, blip in pairs(allBlips) do
        destroyElement(blip)
    end

    local players = getElementsByType("player")
    for k, player in ipairs(players) do
        local team = getPlayerTeam(player)
        local blip
        if player == getGoldCarrier() then
            blip = createBlipAttachedTo ( player, 0 )
	        setElementVisibleTo(blip, player, false)
        else
            if not team then
                blip = createBlipAttachedTo(player, 0, 2, 128, 128, 128)
            else 
                local r,g,b = getTeamColor(team)
                blip = createBlipAttachedTo(player, 0, 2, r, g, b)
            end
        end
        -- push blip to allBlips array
        setElementVisibleTo(blip, player, false)
        table.insert(allBlips, blip)
    end

    if not getGoldCarrier() then
        local goldSpawnEdl = getLastGoldSpawn()
        local posX, posY, posZ = coordsFromEdl(goldSpawnEdl)
        local goldSpawnBlip = createBlip(posX, posY, posZ, 52)
        table.insert(allBlips, goldSpawnBlip)

        local extraBlip = createBlip(posX, posY, posZ, 0, 2, 255, 0, 0, 255, 10)
        table.insert(allBlips, extraBlip)
    else 
        local hideoutEdl = getLastHideout()
        local posX, posY, posZ = coordsFromEdl(hideoutEdl)
        hideoutBlip = createBlip(posX, posY, posZ, 31, 2, 255, 0, 0, 255, 5)
        table.insert(allBlips, hideoutBlip)

        local extraBlip = createBlip(posX, posY, posZ, 0, 2, 255, 0, 0, 255, 10)
        table.insert(allBlips, extraBlip)
    end
end