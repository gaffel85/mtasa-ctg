local preventDieFromWaterCount = 0

function setPreventDieFromWater(value)
    if value then
        preventDieFromWaterCount = preventDieFromWaterCount + 1
    else
        preventDieFromWaterCount = math.max(0, preventDieFromWaterCount - 1)
    end
end

function checkWater()
    if preventDieFromWaterCount > 0 then
        return
    end

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
