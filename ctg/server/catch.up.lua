local checkScoresTimer
local catchUpPowerDisplay = nil

function changeHandlingForPlayer(player, percentage, maxPercentage)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        return
    end

    local originalHandling = getOriginalHandling(getElementModel(vehicle))
    if player == getGoldCarrier() then
        percentage = getConst().goldHandlingCoeff * percentage
        local newMass = originalHandling["mass"] + getConst().goldMass
        setVehicleHandling(vehicle, "mass", newMass)
    else
        setVehicleHandling(vehicle, "mass", originalHandling["mass"])
    end

    local cappedPercentage = math.max(percentage, 0.7)
    local totalPercentage = cappedPercentage * maxPercentage
    
    outputChatBox("Changing handling for "..getPlayerName(player).." to "..totalPercentage)
    setVehicleHandling(vehicle, "maxVelocity", originalHandling["maxVelocity"] * totalPercentage)
    setVehicleHandling(vehicle, "engineAcceleration", originalHandling["engineAcceleration"] * totalPercentage)
end

function handicapHandling(playersWithScore)
    local lowestPercentage = 1
    for _, player in ipairs(playersWithScore) do
        if player.percentage < lowestPercentage then
            lowestPercentage = player.percentage
        end
    end

    local maxPercentage = 1 + getConst().handicapHandlingExtraPercentage
    for _, player in ipairs(playersWithScore) do
        local handlingPercentage = 1 - (player.percentage - lowestPercentage)
        changeHandlingForPlayer(player.player, handlingPercentage, maxPercentage)
    end
end

function scorePercentageForPlayers(players)
    if #players == 0 then return {} end

    -- Find the best score
    local bestScore = 0
    for _, player in ipairs(players) do
        local score = getScoreForCatchup(player) or 0
        if score > bestScore then
            bestScore = score
        end
    end

    -- Notify players below 70% of the best score
    local playesWithScore = {}
    for _, player in ipairs(players) do
        local score = getScoreForCatchup(player) or 0
        local percentage = score / bestScore
        table.insert(playesWithScore, {player = player, score = score, percentage = percentage})
    end
    return playesWithScore
end

function shouldShowCatchupPower(player)
    if not isFarEnoughFromLeader(player.player) then
        return false
    end

    local targetX, targetY, targetZ = findTargetPos()
    local meanPositionOfAllPlayers = meanPositionAndRotationOfElements(playersExceptMe(player.player))

    local alternativePos, useOwnPos = meanPositionOrMyOwn(player.player, {x = targetX, y = targetY, z = targetZ}, meanPositionOfAllPlayers)

    if player.percentage < 0.9 then
        --outputChatBox("Below 90% of the best score "..inspect(player.percentage))
        return true
    else
        return not useOwnPos
    end
end

-- Function to compare scores and notify players
local function compareScores()
    local playersWithScore = scorePercentageForPlayers(getElementsByType("player"))
    for _, player in ipairs(playersWithScore) do
        if shouldShowCatchupPower(player) then 
            notfiyToUseCatchupPower(player.player)
        else 
            stopNotifyingCatchupPower(player.player)
        end
    end
    handicapHandling(playersWithScore)
end

function stopNotifyingCatchupPower(player)
    if catchUpPowerDisplay then
        textDisplayRemoveObserver ( catchUpPowerDisplay, player )
    end
end

function notfiyToUseCatchupPower(player)
    --outputChatBox("Should show catchup power for "..getPlayerName(player))
    if not catchUpPowerDisplay then
        createMessageDisplay()
    end
    textDisplayAddObserver ( catchUpPowerDisplay, player )
end

function createMessageDisplay()
    catchUpPowerDisplay = textCreateDisplay ()
    local howToEnableItem = textCreateTextItem ( "Press Z to catch up", 0.5, 0.7, "medium", 255, 255, 255, 255, 3, "center", "top", 200) 
    local messageItem = textCreateTextItem ( "You are far away from other players, that's ntot fun!", 0.5, 0.74, "medium", 200, 200, 255, 255, 1.5, "center", "top", 200) 
    textDisplayAddText ( catchUpPowerDisplay, messageItem )
    textDisplayAddText ( catchUpPowerDisplay, howToEnableItem )
end

function meanPositionOrMyOwn(player, targetPos, meanPositionOfAllPlayersExceptMe)
    local x, y, z = getElementPosition(player)
    if #meanPositionOfAllPlayersExceptMe <= 1 then
        return { x = x, y = y, z = z }, true
    end

    --outputServerLog("Player pos "..getPlayerName(player) ..": "..inspect({x, y, z}))
    local distanceToTargetPos = getDistanceBetweenPoints3D(x, y, z, targetPos.x, targetPos.y, targetPos.z)
    --outputServerLog("Distance to target pos: "..distanceToTargetPos)
    local distanceFromMeanPosition = getDistanceBetweenPoints3D(targetPos.x, targetPos.y, targetPos.z, meanPositionOfAllPlayersExceptMe.x, meanPositionOfAllPlayersExceptMe.y, meanPositionOfAllPlayersExceptMe.z)
    --outputServerLog("Distance from mean pos: "..distanceFromMeanPosition)
    local alternativePos = meanPositionOfAllPlayersExceptMe
    local useOwnPos = false
    if distanceToTargetPos < distanceFromMeanPosition then
        --outputServerLog("Using own pos")
        alternativePos = { x = x, y = y, z = z }
        useOwnPos = true
    end

    return alternativePos, useOwnPos
end

function useCatchUp(player)
    if isFarEnoughFromLeader(player) then
        local playersWithScore = scorePercentageForPlayers(getElementsByType("player"))
        if #playersWithScore == 0 then
            return
        end
        local myPercentage = 1
        for _, playerWithScore in ipairs(playersWithScore) do
            if playerWithScore.player == player then
                myPercentage = playerWithScore.percentage
                break
            end
        end
        local leader = findLeader(player)
	    if (not leader or leader == player) then
		    outputServerLog("No leader found for useCatchUp")
		    return
	    end

        local targetX, targetY, targetZ = findTargetPos()
        local targetPos = {x = targetX, y = targetY, z = targetZ}
        local meanPositionOfAllPlayers = meanPositionAndRotationOfElements(playersExceptMe(player))
        local alternativePos, useOwnPos = meanPositionOrMyOwn(player, targetPos, meanPositionOfAllPlayers)

        if myPercentage < 0.7 then
            outputChatBox("Use Below 70% of the best score "..inspect(myPercentage))
            askForLocationNbr(player, leader, 1, "teleportOr", targetPos, alternativePos)
        elseif myPercentage < 0.8 then
            outputChatBox("Use Below 80% of the best score "..inspect(myPercentage))
            askForLocationNbr(player, leader, 3, "teleportOr", targetPos, alternativePos)
        elseif myPercentage < 0.9 then
            outputChatBox("Use Below 90% of the best score "..inspect(myPercentage))
            askForLocationNbr(player, leader, 5, "teleportOr", targetPos, alternativePos)
        else
            outputChatBox("Use above 90% of the best score. "..inspect(myPercentage).." Using useOwnPos? "..inspect(useOwnPos))
            if not useOwnPos then
                spawnCloseTo(player, meanPositionOfAllPlayers)
            end
            
        end
    end
end

-- Start the timer when the resource starts
addEventHandler("onResourceStart", resourceRoot, function()
    checkScoresTimer = setTimer(compareScores, 5000, 0) -- 5 seconds
end)

-- Stop the timer when the resource stops
addEventHandler("onResourceStop", resourceRoot, function()
    if isTimer(checkScoresTimer) then
        killTimer(checkScoresTimer)
    end
end)

-- Helper function to get a player's score (replace with your actual scoring logic)
function getScoreForCatchup(player)
    return getPlayerScore(player)
end

registerBindFunctions(function(player)
    bindKey(player, "z", "up", useCatchUp)
end, function(player)
    unbindKey(player, "z", "up", useCatchUp)
end)