local GATHER_WARNING_TEXT_ID = 5823941

function playersToGatherAndNot(x, y, z, radius)
    local players = getElementsByType("player")
    local playersToGather = {}
    local playersNotToGather = {}
    for i, player in ipairs(players) do
        local px, py, pz = getElementPosition(player)
        local distanceFromPos = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
        if distanceFromPos > radius then
            table.insert(playersToGather, player)
        else
            table.insert(playersNotToGather, player)
        end
    end
    return playersToGather, playersNotToGather
end

function gatherPlayersAt(x, y, z, radius, countdownSeconds)

    outputServerLog("3 "..inspect(radius).." "..inspect(x).." "..inspect(y).." "..inspect(z))
    local players = getElementsByType("player")
    if #players == 0 then
        return
    end

    local playersToGather = playersToGatherAndNot(x, y, z, radius)
    preparePlayersForGathering(playersToGather, countdownSeconds)
    setTimer(teleportPlayers, countdownSeconds * 1000, 1, playersToGather, { x = x, y = y, z = z }, radius)
end

function preparePlayersForGathering(players, countdownSeconds)
    for i, player in ipairs(players) do
        fadeCamera(player, false, 0.5)
        countDownTextForPlayer(countdownSeconds, player, GATHER_WARNING_TEXT_ID, "Telepor to starting area in", 0.5, 0.5, 88, 255, 120, 255, 4)
    end
end

function notifyNewPlayersToGather(players)
    for i, player in ipairs(players) do
        fadeCamera(player, false, 0.2)
        displayMessageForPlayer(player, GATHER_WARNING_TEXT_ID, "You were telported to starting area", 0.5, 0.5, 88, 255, 120, 255, 4)
        setTimer(function()
            fadeCamera(player, true, 0.5)
        end, 500, 1)
    end
end

function teleportPlayers(players, position, radius)
    local playersToGather, playersNotToGather = playersToGatherAndNot(position.x, position.y, position.z, radius)
    --local meanPosition, meanRotation = meanPositionAndRotationOfElements(playersNotToGather)
    --outputServerLog("Teleporting players "..inspect(playersToGather))

    -- diff between players and playersToGather
    local newPlayersToGather = {}
    for i, player in ipairs(playersToGather) do
        if not contains(players, player) then
            table.insert(newPlayersToGather, player)
        end
    end
    notifyNewPlayersToGather(newPlayersToGather)
    outputServerLog("Found "..#newPlayersToGather.." players to gather. "..inspect(newPlayersToGather))
    --outputServerLog("All locations "..inspect( getAllLocations()))
    
    local allLocations = getLocations(position.x, position.y, position.z, 100)
    --plotAllPositions2(allLocations)
    --outputServerLog("Possible locations"..inspect(#allLocations))
    local locationsToUse = getRotatedLocationsOrOther(allLocations, #playersToGather, true)
    --outputServerLog("Shuffled locations"..inspect(#locationsToUse))
    plotAllPositions2(locationsToUse)
    -- move each player to one of the locations
    for i, player in ipairs(playersToGather) do
        local location = locationsToUse[i%#locationsToUse + 1]
        --outputServerLog("Using for player "..getPlayerName(player)..": "..inspect(location))
        if location then
            local vehicle = getPedOccupiedVehicle(player)
            if vehicle then
                if not setElementPosition(vehicle, location.x, location.y, location.z + 2) then
                    outputServerLog("Failed to teleport player "..getPlayerName(player).. " to "..location.x..", "..location.y..", "..location.z)
                end
                if not setElementRotation(vehicle, location.rx, location.ry, location.rz) then
                    outputServerLog("Failed to rotate player "..getPlayerName(player).." to "..location.rx..", "..location.ry..", "..location.rz)
                end
            end
            fadeCamera(player, true, 0.5)
        end
    end
end

local blips = {}
function plotPosition2(x, y, z)
    -- plot a position in the world
    local blip = createBlip(x, y, z, 0, 2, 0, 255, 255, 255, 0)
    table.insert(blips, blip)
end

function destroyOldBlips2()
    for i, blip in ipairs(blips) do
        if isElement(blip) then
            destroyElement(blip)
        end
    end
    blips = {}
end

function plotAllPositions2(locations)
    destroyOldBlips2()
    for i, location in ipairs(locations) do
        plotPosition2(location.x, location.y, location.z)
    end
end