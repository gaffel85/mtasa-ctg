local ghosts = {}

function isGhost(player)
    return ghosts[player] ~= nil
end

function getVechicleSafeRadius(vehicle)
    local radius, minx, miny, minz, maxx, maxy, maxz = getVehicleBoundingBoxData(vehicle)
    -- outputServerLog("Radius: "..radius)
    --local distanceFromCenterToMax = getDistanceBetweenPoints3D(0, 0, 0, maxx, maxy, maxz)
    --local distanceFromCenterToMin = getDistanceBetweenPoints3D(0, 0, 0, minx, miny, minz)
    --local radius = math.max(distanceFromCenterToMax, distanceFromCenterToMin)
    return radius
end

function checkSafeFromCollision(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputConsole("No vehicle for "..getPlayerName(player), player)
        return true
    end

    local myRadius = getVechicleSafeRadius(vehicle)
    local x, y, z = getElementPosition(vehicle)
    local safe = true
    for i, otherPlayer in ipairs(getElementsByType("player")) do
        outputConsole("Loop all players, now "..getPlayerName(otherPlayer).." "..getPlayerName(player), player)
        if otherPlayer ~= player then --and not isGhost(otherPlayer) then
            outputConsole(getPlayerName(otherPlayer).." is not ghost "..getPlayerName(player), player)
            local otherVehicle = getPedOccupiedVehicle(otherPlayer)
            if otherVehicle then
                outputConsole("Other vehicle for "..getPlayerName(otherPlayer).." "..getPlayerName(player), player)
                local ox, oy, oz = getElementPosition(otherVehicle)
                local otherRadius = getVechicleSafeRadius(otherVehicle)
                if getDistanceBetweenPoints3D(x, y, z, ox, oy, oz) < (myRadius + otherRadius) then
                    outputConsole("Collision detected for "..getPlayerName(otherPlayer).." "..getPlayerName(player), player)
                    safe = false
                    break
                end
            end
        end
    end
    return safe
end

function timerOutGhost(player)
    outputConsole("1 "..getPlayerName(player), player)
    local record = ghosts[player]
    if record and record.safeCheck then
        if checkSafeFromCollision(player) then
            outputConsole("Was safe from collision "..getPlayerName(player), player)
            unmakePlayerGhost(player)
        else
            outputConsole("Had collision, polling..."..getPlayerName(player), player)
            record.seconds = math.random(8, 12) / 10
            record.timer = setTimer(function()
                timerOutGhost(player)
            end, record.seconds * 1000, 1)
        end
    else
        outputConsole("2 "..getPlayerName(player), player)
        unmakePlayerGhost(player) 
    end
end

function unmakePlayerGhost(player)
    local record = ghosts[player]
    if record then
        if isTimer(record.timer) then
            killTimer(record.timer)
        end
        ghosts[player] = nil
        triggerClientEvent("unmakeGhostFromServer", getRootElement(), player)
    end
end

function makePlayerGhost(player, seconds, safeCheck, invisible)
    if isGhost(player) then
        -- extend timer
        local record = ghosts[player]
        if record.timer then
            killTimer(record.timer)
        end
        record.seconds = seconds
        record.safeCheck = safeCheck
        record.invisible = invisible
        record.timer = setTimer(function()
            timerOutGhost(player)
        end, seconds * 1000, 1)
    else
        ghosts[player] = {
            seconds = seconds,
            safeCheck = safeCheck,
            invisible = invisible,
            timer = setTimer(function()
                timerOutGhost(player)
            end, seconds * 1000, 1)
        }
        triggerClientEvent("makeGhostFromServer", getRootElement(), player, invisible)
    end
end

function togglePlayerGhost(player)
    if isGhost(player) then
        unmakePlayerGhost(player)
    else
        makePlayerGhost(player, 5, true, false)
    end
end

registerBindFunctions(function(player)
    bindKey(player, "g", "down", togglePlayerGhost)
end, function(player)
    unbindKey(player, "g", "down", togglePlayerGhost)
end)

addEventHandler("onPlayerJoin", getRootElement(), function ()
    for i, player in ipairs(getElementsByType("player")) do
        if isGhost(player) then
            local record = ghosts[player]
            triggerClientEvent("makeGhostFromServer", getRootElement(), player, record.invisible)
        end
    end
end)

