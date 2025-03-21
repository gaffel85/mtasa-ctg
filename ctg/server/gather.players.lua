local GATHER_WARNING_TEXT_ID = 5823941

function gatherPlayersAt(x, y, z, radius, countdownSeconds)
    local players = getElementsByType("player")
    if #players == 0 then
        return
    end

    local playersToGather = {}
    local meanRotation = { x = 0, y = 0, z = 0 }
    local meanPosition = 0
    for i, player in ipairs(getElementsByType("player")) do
        local px, py, pz = getElementPosition(player)
        if getDistanceBetweenPoints3D(x, y, z, px, py, pz) > radius then
            table.insert(playersToGather, player)
        else
            meanPosition.x = meanPosition.x + px
            meanPosition.y = meanPosition.y + py
            meanPosition.z = meanPosition.z + pz
            local rx, ry, rz = getElementRotation(player)
            meanRotation = meanRotation + rz
        end
    end

    meanPosition = { x = meanPosition.x / #players, y = meanPosition.y / #players, z = meanPosition.z / #players }
    meanRotation = meanRotation / #players
    
    preparePlayersForGathering(playersToGather, countdownSeconds)
    setTimer(teleportPlayers, countdownSeconds * 1000, 1, playersToGather, meanPosition, meanRotation, { x = x, y = y, z = z })
end

function preparePlayersForGathering(players, countdownSeconds)
    for i, player in ipairs(players) do
        fadeCamera(player, false, 0.5)
        countDownTextForPlayer(player, GATHER_WARNING_TEXT_ID, "Telepor to starting area in", 0.5, 0.4, 88, 255, 120, 255, 4)
    end
end

function teleportPlayers(players, meanPosition, meanRotation, position)
    local allLocations = getLocations(position.x, position.y, position.z, 100)
    local locationsWithRot = {}
    for i, location in ipairs(allLocations) do
        if location.speedMet then
            table.insert(locationsWithRot, location)
        end
    end

    local locationsToUse = locationsWithRot
    if #locationsWithRot == 0 then
        locationsToUse = allLocations
    end
  
    --random location
    local shuffledLocations = shuffle(locationsToUse)
    -- move each player to one of the locations
    for i, player in ipairs(players) do
        local location = shuffledLocations[i]
        if location then
            setElementPosition(player, location.x, location.y, location.z)
            setElementRotation(player, location.rx, location.ry, location.rz)
            fadeCamera(player, true, 0.5)
        end
    end
end

function shuffle(tbl)
    local shuffled = {}
    for i = #tbl, 1, -1 do
        local rand = math.random(i)
        tbl[i], tbl[rand] = tbl[rand], tbl[i]
    end
    return tbl
end