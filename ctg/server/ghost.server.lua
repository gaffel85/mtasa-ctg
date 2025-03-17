local ghosts = {}

function isGhost(player)
    return ghosts[player] ~= nil
end

function getVechicleSafeRadius(vehicle)
    local minx, miny, minz, maxx, maxy, maxz = getElementBoundingBox(vehicle)
    local distanceFromCenterToMax = getDistanceBetweenPoints3D(0, 0, 0, maxx, maxy, maxz)
    local distanceFromCenterToMin = getDistanceBetweenPoints3D(0, 0, 0, minx, miny, minz)
    local radius = math.max(distanceFromCenterToMax, distanceFromCenterToMin)
    return radius
end

function checkSafeFromCollision(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        return true
    end

    local myRadius = getVechicleSafeRadius(vehicle)
    local x, y, z = getElementPosition(vehicle)
    local safe = true
    for i, otherPlayer in ipairs(getElementsByType("player")) do
        if otherPlayer ~= player and not isGhost(otherPlayer) then
            local otherVehicle = getPedOccupiedVehicle(otherPlayer)
            if otherVehicle then
                local ox, oy, oz = getElementPosition(otherVehicle)
                local otherRadius = getVechicleSafeRadius(otherVehicle)
                if getDistanceBetweenPoints3D(x, y, z, ox, oy, oz) < (myRadius + otherRadius) then
                    safe = false
                    break
                end
            end
        end
    end
    return safe
end

function timerOutGhost(player)
    local record = ghosts[player]
    if record and record.safeCheck then
        if checkSafeFromCollision(player) then
            unmakePlayerGhost(player)
        else
            record.seconds = math.random(8, 12) / 10
            record.timer = setTimer(function()
                timerOutGhost(player)
            end, record.seconds * 1000, 1)
        end
    else
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
        unmakePlayerGhost(player)
    else
        ghosts[player] = {
            seconds = seconds,
            safeCheck = safeCheck,
            invisible = invisible,
            timer = setTimer(function()
                unmakePlayerGhost(player)
            end, seconds * 1000, 1)
        }
        triggerClientEvent("makeGhostFromServer", getRootElement(), player, invisible)
    end
end

registerBindFunctions(function(player)
    bindKey(player, "g", "down", makePlayerGhost, player, 5, true, false)
end, function(player)
    unbindKey(player, "g", "down", makePlayerGhost, player)
end)

