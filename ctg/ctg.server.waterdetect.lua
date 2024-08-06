-- Timer thath checks if somone is in the water every 3 seconds using the isElementInWater function
function checkWater()
    local players = getElementsByType("player")
    for k, player in ipairs(players) do
        local vechicle = getPedOccupiedVehicle(player)
        if isElementInWater(vehicle) then
            killPed(player, player)
        end
    end
end
setTimer(checkWater, 3000, 9999999999)