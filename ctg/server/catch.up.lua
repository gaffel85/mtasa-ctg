local checkScoresTimer
local catchUpPowerDisplay = nil
local SCORE_PERCENTAGE_TEXT_KEY = "SCORE_PERCENTAGE_TEXT_KEY"
local DISTANCE_PERCENTAGE_TEXT_KEY = "DISTANCE_PERCENTAGE_TEXT_KEY"
local TOTAL_PERCENTAGE_TEXT_KEY = "TOTAL_PERCENTAGE_TEXT_KEY"

function showPercentageForPlayer(player, scorePercentage, distancePercentage, totalPercentage)
    local x = 0.98
    displayMessageForPlayer(player, SCORE_PERCENTAGE_TEXT_KEY, math.floor(scorePercentage * 100).."%", 99999999, x, 0.02, 255, 255, 255, 255, 1)
    displayMessageForPlayer(player, DISTANCE_PERCENTAGE_TEXT_KEY, math.floor(distancePercentage * 100).."%", 99999999, x, 0.04, 255, 255, 255, 255, 1)
    displayMessageForPlayer(player, TOTAL_PERCENTAGE_TEXT_KEY, math.floor(totalPercentage * 100).."%", 99999999, x, 0.06, 255, 255, 255, 255, 1)
end

function changeHandlingForPlayer(player, extraGoldMass, totalPercentage)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        return
    end

    local originalHandling = getOriginalHandling(getElementModel(vehicle))
    local newMass = originalHandling["mass"] + extraGoldMass
    setVehicleHandling(vehicle, "mass", newMass)
    
    --outputChatBox("Handling percentage: "..inspect(totalPercentage).." distancePercentage: "..distancePercentage.." cappedPercentage: "..cappedPercentage.." combinedPercentage: "..combinedPercentage, player)
    --outputChatBox("Changing handling for "..getPlayerName(player).." to "..totalPercentage)
    setVehicleHandling(vehicle, "maxVelocity", originalHandling["maxVelocity"] * totalPercentage)
    setVehicleHandling(vehicle, "engineAcceleration", originalHandling["engineAcceleration"] * totalPercentage)
end

function handicapHandling(playersWithScore)
    local players = playersWithDistanceToLeader(playersWithScore)
    adjustedScorePercentageForPlayers(players)
    goldCarrierPercentageForPlayers(players)

    local highestCombinedPercentage = 0
    local highestPercentagePlayer = nil
    for _, player in ipairs(players) do
        local combinedPercentage = player.scorePercentage * player.distancePercentage * player.goldCarrierPercentage
        if combinedPercentage > highestCombinedPercentage then
            highestCombinedPercentage = combinedPercentage
            highestPercentagePlayer = player.player
        end
    end

    local extraPercentage = 1
    if highestPercentagePlayer then
        local vehicle = getPedOccupiedVehicle(highestPercentagePlayer)
        if vehicle then
            local _, _, _, _, _, _, _, _, maxSpeed = getVehicleSizeData(vehicle)
            extraPercentage = calculateExtraVehiclePercentage(maxSpeed)
            --outputChatBox("Extra percentage: "..extraPercentage, highestPercentagePlayer)
        end
    end

    local coeffToMakeHighestGoTo100 = extraPercentage / highestCombinedPercentage
    for _, player in ipairs(players) do
        local total = coeffToMakeHighestGoTo100 * (player.scorePercentage * player.distancePercentage * player.goldCarrierPercentage)
        player.totalPercentage = math.max(total, getConst().handicapTotalMinPercentage)
        showPercentageForPlayer(player.player, player.scorePercentage, player.distancePercentage, player.totalPercentage)
    end

    for _, player in ipairs(players) do
        changeHandlingForPlayer(player.player, player.extraGoldMass, player.totalPercentage)
    end
end

function calculateExtraVehiclePercentage(maxSpeed)
    -- maxSpeed 50 and below should result in 200% speed
    -- maxSpeed 200 and above should result in 100% speed
    -- interpolate in between
    if maxSpeed < 50 then
        return 2
    elseif maxSpeed > 200 then
        return 1
    else
        return (7/3) - (maxSpeed / 150)
    end
end

function goldCarrierPercentageForPlayers(players)
    for _, player in ipairs(players) do
        if player == getGoldCarrier() then
            player.goldCarrierPercentage = getConst().goldHandlingCoeff
            player.extraGoldMass = getConst().goldMass
        else
            player.goldCarrierPercentage = 1
            player.extraGoldMass = 0
        end
    end
end

function adjustedScorePercentageForPlayers(playersWithScore)
    local lowestPercentage = 1
    for _, player in ipairs(playersWithScore) do
        if player.percentage < lowestPercentage then
            lowestPercentage = player.percentage
        end
    end

    local maxPercentage = 1 + getConst().handicapHandlingExtraPercentage
    for _, player in ipairs(playersWithScore) do
        local handlingPercentage = 1 - (player.percentage - lowestPercentage)
        player.scorePercentage = math.max(handlingPercentage, getConst().handicapHandlingMinPercentage)
    end
end

function playersWithDistanceToLeader(playersWithScore)
    local playersWithDistance = {}
    local leader = getGoldCarrier()
    for _, player in ipairs(playersWithScore) do
        if leader then
            local x1, y1, z1 = getElementPosition(player.player)
            local x2, y2, z2 = getElementPosition(leader)
            -- outputServerLog("Positions to compare: "..inspect({x1, y1, z1}).." - "..inspect({x2, y2, z2}))
            local distance = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
            table.insert(playersWithDistance, {player = player.player, distance = distance, percentage = player.percentage})
        else
            table.insert(playersWithDistance, {player = player.player, distance = 0, percentage = player.percentage})
        end
    end

    local distanceLimit = 300
    local biggestDistanceInLimit = 0
    for _, player in ipairs(playersWithDistance) do
        if player.distance < distanceLimit then
            if player.distance > biggestDistanceInLimit then
                biggestDistanceInLimit = player.distance
            end
        end
    end

    local maxDistanceHandicap = getConst().handicapHandlingMaxForDistance -- 0.5
    local extraDistanceToAdd = distanceLimit - biggestDistanceInLimit
    for _, player in ipairs(playersWithDistance) do
        local distancePercentage = 1
        if biggestDistanceInLimit > 0 then
            local distancePercentBeforeCap = math.min((player.distance + extraDistanceToAdd) / distanceLimit, 1)
            distancePercentage = (1 - maxDistanceHandicap) + distancePercentBeforeCap * maxDistanceHandicap
        end
        player.distancePercentage = distancePercentage
    end

    return playersWithDistance
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

    local _, _, useOwnPos = alternativePos(player.player)
    return not useOwnPos
end

function alternativePos(player)
    local leader = findLeader(player)
    if (not leader or leader == player) then
        outputServerLog("No leader found for useCatchUp")
        return nil, nil, true, nil
    end

    local targetX, targetY, targetZ = findTargetPos()
    local targetPos = {x = targetX, y = targetY, z = targetZ}
    local playerExceptMe = playersExceptMe(player)
    local meanPositionOfAllPlayers = meanPositionAndRotationOfElements(playerExceptMe)

    local x, y, z = getElementPosition(player)
    local alternativePos = nil
    local useOwnPos = false
    if #playerExceptMe < 1 then
        alternativePos = { x = x, y = y, z = z }
        useOwnPos = true
    else
        alternativePos, useOwnPos = meanPositionOrMyOwn(x, y, z, targetPos, meanPositionOfAllPlayers)
    end

    return leader, alternativePos, useOwnPos, targetPos, meanPositionOfAllPlayers, playerExceptMe
end

function useCatchUp(player)
    --cameraFly(extractPositions(inputData), player, 360)

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
        
        local leader, alternativePos, useOwnPos, targetPos, meanPositionOfAllPlayers, playerExceptMe = alternativePos(player)
        if not leader then
            return
        end

        if #playerExceptMe <= 1 then
            useOwnPos = true
        end

        if myPercentage < 0.7 then
            outputChatBox("Use Below 70% of the best score "..inspect(myPercentage))
            askForLocationNbr(player, leader, 3, "teleportOr", targetPos, alternativePos)
        elseif myPercentage < 0.8 then
            outputChatBox("Use Below 80% of the best score "..inspect(myPercentage))
            askForLocationNbr(player, leader, 5, "teleportOr", targetPos, alternativePos)
        elseif myPercentage < 0.9 then
            outputChatBox("Use Below 90% of the best score "..inspect(myPercentage))
            askForLocationNbr(player, leader, 7, "teleportOr", targetPos, alternativePos)
        else
            outputChatBox("Use above 90% of the best score. "..inspect(myPercentage).." Using useOwnPos? "..inspect(useOwnPos))
            if not useOwnPos then
                spawnCloseTo(player, meanPositionOfAllPlayers)
            end
            
        end
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

function meanPositionOrMyOwn(x, y, z, targetPos, meanPositionOfAllPlayersExceptMe)
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

-- Input data
local inputData = {
 { -1829.1313476562, -488.90563964844, 13.9609375, 0.81396484375, 3.0842895507812, 357.37976074219, true }, 
 { -1826.662109375, -470.83471679688, 13.9609375, 0.5390625, 358.5576171875, 351.03839111328, true }, 
 { -1822.7362060547, -451.49465942383, 13.9609375, 0.4925537109375, 359.96325683594, 347.67346191406, true }, 
 { -1818.6512451172, -431.72024536133, 13.9609375, 0.4644775390625, 0.27099609375, 348.95324707031, true }, 
 { -1814.6475830078, -411.24554443359, 14.635078430176, 2.902587890625, 0.6376953125, 348.97924804688, true }, 
 { -1810.947265625, -390.25073242188, 15.971983909607, 4.6015625, 0.97625732421875, 350.72088623047, true }, 
 { -1807.4334716797, -368.88082885742, 17.649633407593, 4.996826171875, 0.7940673828125, 350.72375488281, true }, 
 { -1803.8828125, -347.40454101562, 20.264532089233, 7.5559692382812, 1.2676391601562, 350.79968261719, true }, 
 { -1798.1461181641, -260.28005981445, 18.57975769043, 355.755859375, 359.53845214844, 1.8715209960938, true },
  { -1798.1359863281, -237.27125549316, 17.2265625, 1.87646484375, 0.01953125, 359.32849121094, true }, 
  { -1795.8460693359, -180.57836914062, 10.913122177124, 349.21801757812, 356.39489746094, 349.86364746094, true },
 { -1792.6262207031, -164.03262329102, 8.0904922485352, 352.77673339844, 358.17224121094, 355.49615478516, true }, 
 { -1792.2181396484, -146.45108032227, 5.7168321609497, 353.09851074219, 0.726806640625, 1.6904907226562, true }, 
 { -1797.2772216797, -130.51167297363, 4.7193112373352, 356.59643554688, 2.147705078125, 29.6318359375, true }, 
 { -1807.8901367188, -119.67084503174, 4.5, 0.1292724609375, 2.79931640625, 61.293579101562, true }, 
 { -1821.8321533203, -116.23868560791, 4.4975337982178, 0.4710693359375, 1.4754638671875, 85.947082519531, true },
  { -1836.9775390625, -114.59714508057, 4.4921875, 0.4454345703125, 359.39245605469, 82.461059570312, true }, 
  { -1853.2700195312, -113.65763092041, 5.0355110168457, 9.6516723632812, 359.87646484375, 87.446411132812, true }, 
  { -1869.0939941406, -111.30980682373, 9.2256126403809, 19.57470703125, 357.17523193359, 72.358764648438, true }, 
  { -1883.8470458984, -105.61121368408, 14.485778808594, 18.914428710938, 355.40545654297, 63.126342773438, true }, 
  { -1905.7778320312, -86.425262451172, 22.568838119507, 12.764343261719, 0.799560546875, 37.048950195312, true }, 
  { -1915.2268066406, -75.467163085938, 24.462203979492, 3.3271484375, 0.837890625, 44.275451660156, true },
{ -1925.6380615234, -67.293815612793, 24.5546875, 0.45159912109375, 2.37353515625, 67.684814453125, true }, 
{ -1938.3424072266, -65.128234863281, 24.5546875, 0.47088623046875, 2.0657958984375, 100.390625, true }, 
{ -1962.2593994141, -73.273796081543, 24.775037765503, 1.5411376953125, 357.03442382812, 95.031372070312, true }, 
{ -1970.9038085938, -71.71501159668, 25.704200744629, 11.637451171875, 3.257568359375, 69.283081054688, true }, 
{ -1980.2143554688, -70.389038085938, 28.602346420288, 21.315002441406, 5.484619140625, 85.716125488281, true },
 { -1989.8668212891, -68.88646697998, 32.465167999268, 20.43994140625, 2.833740234375, 85.181701660156, true }, 
 { -2009.6359863281, -67.172958374023, 34.165355682373, 1.03564453125, 356.99273681641, 66.505310058594, true }, 
 { -2015.4718017578, -59.580505371094, 34.3203125, 0.7371826171875, 357.84143066406, 18.517578125, true }, 
 { -2014.4957275391, -49.906311035156, 34.3203125, 0.52227783203125, 358.6328125, 335.14208984375, true }, 
 { -2011.1193847656, -39.475574493408, 34.161563873291, 0.0208740234375, 5.8623046875, 348.55419921875, true }, 
 { -2010.4096679688, -27.755237579346, 34.064254760742, 0.01959228515625, 359.42199707031, 2.494140625, true } 
    }

-- Function to extract positions
local function extractPositions(data)
    local positions = {}
    for _, entry in ipairs(data) do
        local position = {
            x = entry[1],
            y = entry[2],
            z = entry[3] + 2
        }
        table.insert(positions, position)
    end
    return positions
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