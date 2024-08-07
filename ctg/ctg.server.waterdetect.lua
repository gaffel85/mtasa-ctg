function checkWater()
    local players = getElementsByType("player")
    for k, player in ipairs(players) do
        local vechicle = getPedOccupiedVehicle(player)
        if isElementInWater(player) then
            if player == getGoldCarrier() then
                removeOldHideout()
                respawnGold()
            end
            killPed(player, player)
        end
    end
end
setTimer(checkWater, 3000, 9999999999)