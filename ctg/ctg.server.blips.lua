local allBlips = {}

function refreshAllBlips()
    destroyElementsByType("blip")
    --for k, blip in ipairs(allBlips) do
    --    destroyElement(blip)
    --end
    allBlips = {}

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
        -- push blip to allBlips array
        setElementVisibleTo(blip, player, false)
        if blip then
            table.insert(allBlips, blip)
        end 
    end

    if not getGoldCarrier() then
        local goldSpawnEdl = getLastGoldSpawn()
        if (goldSpawnEdl) then
            local posX, posY, posZ = coordsFromEdl(goldSpawnEdl)
            local goldSpawnBlip = createBlip(posX, posY, posZ, 52)
            table.insert(allBlips, goldSpawnBlip)

            local extraBlip = createBlip(posX, posY, posZ, 0, 2, 255, 0, 0, 255, 10)
            table.insert(allBlips, extraBlip)
        end
    else 
        local hideoutEdl = getLastHideout()
        outputChatBox("Hide: "..inspect(hideoutEdl))
        if hideoutEdl then
            local posX, posY, posZ = coordsFromEdl(hideoutEdl)
            outputChatBox("Hide pos: "..inspect(posX).."|"..inspect(posXposY).."|"..inspect(posZ))
            hideoutBlip = createBlip(posX, posY, posZ, 31, 2, 255, 0, 0, 255, 5)
            table.insert(allBlips, hideoutBlip)

            local extraBlip = createBlip(posX, posY, posZ, 0, 2, 255, 0, 0, 255, 10)
            setElementVisibleTo(extraBlip, root, false)
            setElementVisibleTo(extraBlip, getGoldCarrier(), true)
            table.insert(allBlips, extraBlip)
        end
    end
end