function checkWater()
    local players = getElementsByType("player")
    for k, player in ipairs(players) do
        local vechicle = getPedOccupiedVehicle(player)
        if isElementInWater(player) then
            if player == getGoldCarrier() then
                -- removeOldHideout()
                -- trigger client event to report last spawn
                triggerClientEvent(player, "reportLastTransform", resourceRoot, 2, "replaceGold")
            end
            killPed(player, player)
        end
    end
end
setTimer(checkWater, 3000, 0)