local GATHER_WARNING_TEXT_ID = 5823941

function gatherPlayersAt(x, y, z, radius, countdownSeconds)

    outputServerLog("3 "..inspect(radius).." "..inspect(x).." "..inspect(y).." "..inspect(z))
    local players = getElementsByType("player")
    if #players == 0 then
        return
    end

    local playersToGather = {}
    local playersNotToGather = {}
    local meanPosition = { x = 0, y = 0, z = 0 }
    local meanRotation = 0
    for i, player in ipairs(getElementsByType("player")) do
        local px, py, pz = getElementPosition(player)
        local distanceFromPos = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
        outputChatBox("You are "..distanceFromPos.." from the position")
        if distanceFromPos > radius then
            outputChatBox("To far away")
            table.insert(playersToGather, player)
        else
            meanPosition.x = meanPosition.x + px
            meanPosition.y = meanPosition.y + py
            meanPosition.z = meanPosition.z + pz
            local rx, ry, rz = getElementRotation(player)
            meanRotation = meanRotation + rz
            table.insert(playersNotToGather, player)
        end
    end

    if #playersNotToGather == 0 then
        meanPosition = { x = x, y = y, z = z }
        meanRotation = 0
    else
        meanPosition = { x = meanPosition.x / #players, y = meanPosition.y / #players, z = meanPosition.z / #players }
        meanRotation = meanRotation / #players
    end
    
    preparePlayersForGathering(playersToGather, countdownSeconds)
    setTimer(teleportPlayers, countdownSeconds * 1000, 1, playersToGather, meanPosition, meanRotation, { x = x, y = y, z = z })
end

function preparePlayersForGathering(players, countdownSeconds)
    for i, player in ipairs(players) do
        fadeCamera(player, false, 0.5)
        countDownTextForPlayer(countdownSeconds, player, GATHER_WARNING_TEXT_ID, "Telepor to starting area in", 0.5, 0.5, 88, 255, 120, 255, 4)
    end
end

function teleportPlayers(players, meanPosition, meanRotation, position)
    outputServerLog("Teleporting players "..inspect(players))
    --outputServerLog("All locations "..inspect( getAllLocations()))
    
    local allLocations = getLocations(position.x, position.y, position.z, 100)
    plotAllPositions2(allLocations)
    outputServerLog("Possible locations"..inspect(#allLocations))
    local locationsWithRot = {}
    for i, location in ipairs(allLocations) do
        if location.speedMet then
            table.insert(locationsWithRot, location)
        end
    end
    --plotAllPositions2(locationsWithRot)
    outputServerLog("Rot locations"..inspect(#locationsWithRot))

    local locationsToUse = locationsWithRot
    if #locationsWithRot == 0 then
        locationsToUse = allLocations
    end
  
    --random location
    shuffle(locationsToUse)
    outputServerLog("Shuffled locations"..inspect(#locationsToUse))
    --plotAllPositions2(locationsToUse)
    -- move each player to one of the locations
    for i, player in ipairs(players) do
        local location = locationsToUse[i%#locationsToUse + 1]
        if location then
            if not setElementPosition(player, location.x, location.y, location.z) then
                outputServerLog("Failed to teleport player "..getPlayerName(player).. " to "..location.x..", "..location.y..", "..location.z)
            end
            if not setElementRotation(player, location.rx, location.ry, location.rz) then
                outputServerLog("Failed to rotate player "..getPlayerName(player).." to "..location.rx..", "..location.ry..", "..location.rz)
            end
            fadeCamera(player, true, 0.5)
        end
    end
end

local blips = {}
local function plotPosition2(x, y, z)
    -- plot a position in the world
    local blip = createBlip(x, y, z, 0, 2, 0, 255, 255, 255, 0)
    table.insert(blips, blip)
end

local function destroyOldBlips2()
    for i, blip in ipairs(blips) do
        if isElement(blip) then
            destroyElement(blip)
        end
    end
    blips = {}
end

local function plotAllPositions2(locations)
    destroyOldBlips2()
    for i, location in ipairs(locations) do
        plotPosition2(location.x, location.y, location.z)
    end
end