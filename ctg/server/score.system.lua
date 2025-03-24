local periodicTimer = nil
local highestScore = 10
local maxDiffDistance = 100
local coeff = -highestScore / maxDiffDistance

function distributePointsByDistanceToGold(players)
    local leader = nil
    local playersWithDistance = {}
    for i, player in ipairs(players) do
        local distance = getDistanceToGold(player)
        local record = {player = player, distance = distance}
        table.insert(playersWithDistance, record)
        
        if distance < leader.distance then
            leader = record
        end
    end

    if not leader then
        return
    end

    for i, record in ipairs(playersWithDistance) do
        local diff = leader.distance - record.distance
        local score = highestScore + coeff * diff
        if score > 0 then
            givePointsToPlayer(record.player, score)
        end
    end
end

function distributePointsByDistanceToGoldCarrier(players, goldCarrier)
    local playersWithDistance = {}
    local gx, gy, gz = getElementPosition(goldCarrier)
    for i, player in ipairs(players) do
        local x, y, z = getElementPosition(player)
        local distance = getDistanceBetweenPoints3D(x, y, z, gx, gy, gz)
        local record = {player = player, distance = distance}
        table.insert(playersWithDistance, record)
    end

    for i, record in ipairs(playersWithDistance) do
        local score = highestScore + coeff * record.distance
        if score > 0 then
            givePointsToPlayer(record.player, score)
        end
    end
end

function distributePoints()
    local players = getElementsByType("player")
    if #players == 0 then
        return
    end

    local goldCarrier = getGoldCarrier()
    if goldCarrier then
        distributePointsByDistanceToGoldCarrier(players, goldCarrier)
    else
        distributePointsByDistanceToGold(players)
    end
end

-- start periodic timer when resource starts
addEventHandler("onResourceStart", resourceRoot,
    function()
        if periodicTimer then
            killTimer(periodicTimer)
        end
        periodicTimer = setTimer(distributePoints, 2000, 9999999999)
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function()
        if periodicTimer then
            killTimer(periodicTimer)
        end
    end
)