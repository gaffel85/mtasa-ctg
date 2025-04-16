local checkScoresTimer
local catchUpPowerDisplay = nil
local SCORE_PERCENTAGE_TEXT_KEY = "SCORE_PERCENTAGE_TEXT_KEY"
local DISTANCE_PERCENTAGE_TEXT_KEY = "DISTANCE_PERCENTAGE_TEXT_KEY"
local TOTAL_PERCENTAGE_TEXT_KEY = "TOTAL_PERCENTAGE_TEXT_KEY"

-- Lua function to calculate initial velocity for a projectile throw
-- Assumes Z-axis is vertical. Angle is relative to the XY plane.

-- Small value for floating point comparisons
local EPSILON = 1e-6

---
-- Calculates the initial velocity needed to throw an object from pos1 to pos2
-- at a given angle relative to the horizontal plane (XY).
--
-- @param pos1 Table containing start position {x, y, z}
-- @param pos2 Table containing target position {x, y, z}
-- @param angle_deg The launch angle in degrees relative to the horizontal (XY) plane.
--                  Typically between 0 (horizontal) and 90 (vertical).
-- @param gravity The magnitude of gravitational acceleration (positive value, e.g., 9.81).
-- @return float vx, float vy, float vz The components of the initial velocity vector.
-- @return nil, nil, nil If the target is unreachable with the given parameters.
---
function getInitialThrowVelocity(pos1, pos2, angle_deg, gravity)
    -- Ensure gravity is a positive magnitude
    gravity = math.abs(gravity)
    if gravity < EPSILON then
        -- Gravity is effectively zero, straight line path
        -- This requires different logic, or we can return nil as projectile math breaks down.
        -- Let's assume gravity must be present for this parabolic calculation.
        print("Error: Gravity must be a positive value.")
        return nil, nil, nil
    end

    -- 1. Calculate Displacement Vector
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z -- Vertical displacement (Z is up)

    -- 2. Calculate Horizontal Distance (in XY plane)
    local d_h_squared = dx*dx + dy*dy
    local d_h = math.sqrt(d_h_squared)

    -- 3. Convert Angle to Radians
    local theta_rad = math.rad(angle_deg)
    local cos_theta = math.cos(theta_rad)
    local sin_theta = math.sin(theta_rad)
    -- Avoid issues with tan(90 degrees) later if possible
    local tan_theta = nil
    if math.abs(cos_theta) > EPSILON then
       tan_theta = sin_theta / cos_theta
    end

    -- 4. Handle Edge Cases

    -- Case: Target is (almost) directly above or below (d_h is near zero)
    if d_h < EPSILON then
        if math.abs(dz) < EPSILON then
             -- Target is at the same position as start, velocity should be zero.
             return 0, 0, 0
        end
        -- For a purely vertical throw, the angle must be ~90 degrees.
        if math.abs(angle_deg - 90.0) < EPSILON then
            -- Calculate vertical speed needed using v_final^2 = v_initial^2 + 2*a*s
            -- 0 = v0z^2 + 2*(-gravity)*dz => v0z^2 = 2*gravity*dz
            if dz < 0 then
                 -- Cannot throw vertically *up* (angle=90) and reach a point *below*.
                 print("Warning: Cannot throw vertically up (angle 90) to reach target below.")
                 return nil, nil, nil
            end
            local v0z_squared = 2 * gravity * dz
            if v0z_squared < 0 then -- Should not happen if dz >= 0 and gravity > 0
                 print("Error: Vertical velocity calculation failed.")
                 return nil, nil, nil
            end
            local v0z = math.sqrt(v0z_squared)
            return 0, 0, v0z
        else
            -- Cannot hit a target directly above/below with a non-90-degree angle.
            print("Warning: Cannot hit target directly above/below with a non-vertical angle.")
            return nil, nil, nil
        end
    end

    -- Case: Angle is +/- 90 degrees (but d_h is not zero)
    if math.abs(cos_theta) < EPSILON then
        -- A vertical launch cannot cover horizontal distance.
        print("Warning: Cannot throw horizontally with a vertical (90 degree) angle.")
        return nil, nil, nil
    end

    -- Now tan_theta should be valid because cos_theta is not zero
    tan_theta = tan_theta or (sin_theta / cos_theta) -- Calculate if not already done

    -- 5. Calculate Initial Speed 's' using the derived formula

    -- Formula: s^2 = (g * d_h^2) / (2 * cos^2(theta) * (d_h * tan(theta) - dz))
    local denominator_part = d_h * tan_theta - dz

    -- Check if the target is reachable (term in sqrt must be positive)
    -- Requires denominator_part > 0 (since g, d_h^2, cos^2 are positive)
    if denominator_part <= EPSILON then
        print("Warning: Target is too high or calculation unstable for the given angle and distance.")
        return nil, nil, nil
    end

    local s_squared_numerator = gravity * d_h_squared
    local s_squared_denominator = 2 * cos_theta * cos_theta * denominator_part

    -- Denominator should be positive if denominator_part > 0 and cos_theta != 0
    if s_squared_denominator <= EPSILON then
         print("Error: Speed calculation denominator is zero or negative (unexpected).")
         return nil, nil, nil
    end

    local s_squared = s_squared_numerator / s_squared_denominator

    -- Numerical stability check
    if s_squared < 0 then
         print("Error: Calculation resulted in negative speed squared (unexpected).")
         return nil, nil, nil
    end

    local s = math.sqrt(s_squared)

    -- 6. Construct the Initial Velocity Vector (vx, vy, vz)

    -- Vertical component
    local vz = s * sin_theta

    -- Horizontal components
    local v_horizontal = s * cos_theta
    local vx = v_horizontal * (dx / d_h) -- Distribute horizontal speed based on dx/d_h ratio
    local vy = v_horizontal * (dy / d_h) -- Distribute horizontal speed based on dy/d_h ratio

    return vx, vy, vz
end

function teleportToOr2(player, transform, targetPos, optionalPos)
    local vehicle = getPedOccupiedVehicle(player)
    if (not vehicle) then
        return
    end
    local x, y, z = getElementPosition(vehicle)
    local pos1 = { x = x, y = y, z = z }
    local launch_angle = 75 -- degrees
    local gravity = 9.81 -- m/s^2 (standard gravity)
    local vx, vy, vz = getInitialThrowVelocity(pos1, targetPos, launch_angle, gravity)
    if vx and vy and vz then
        -- Set the velocity of the vehicle
        setElementVelocity(vehicle, vx, vy, vz)
        -- Set the position of the vehicle to the target position
        --setElementPosition(vehicle, targetPos.x, targetPos.y, targetPos.z + 2)
    else
        outputChatBox("Target unreachable with given parameters.")
    end
end

-- Example Usage:
-- Define start and end positions (as tables with x, y, z)
-- local startPos = { x = 0, y = 0, z = 1 }
-- local targetPos = { x = 15, y = 10, z = 5 }
-- local launchAngle = 45 -- degrees
-- local gravityValue = 9.81

-- Calculate the velocity
-- local vx, vy, vz = getInitialThrowVelocity(startPos, targetPos, launchAngle, gravityValue)

-- Check if calculation was successful and apply the velocity
-- if vx and vy and vz then
--    print(string.format("Calculated Initial Velocity: vx=%.3f, vy=%.3f, vz=%.3f", vx, vy, vz))
--    -- Assuming 'myThrowableObject' is the element you want to throw
--    -- setElementVelocity(myThrowableObject, vx, vy, vz)
-- else
--    print("Failed to calculate the required initial velocity. Target might be unreachable.")
-- end

-- Another test case: Throwing almost straight up
-- local startPos2 = { x = 0, y = 0, z = 0 }
-- local targetPos2 = { x = 0.1, y = 0.1, z = 10 }
-- local launchAngle2 = 85
-- local vx2, vy2, vz2 = getInitialThrowVelocity(startPos2, targetPos2, launchAngle2, gravityValue)
-- if vx2 then print(string.format("Case 2 Velocity: vx=%.3f, vy=%.3f, vz=%.3f", vx2, vy2, vz2)) else print("Case 2 Failed") end

-- Test case: Impossible angle
-- local startPos3 = { x = 0, y = 0, z = 0 }
-- local targetPos3 = { x = 10, y = 10, z = 100 } -- Likely too high for this angle
-- local launchAngle3 = 30
-- local vx3, vy3, vz3 = getInitialThrowVelocity(startPos3, targetPos3, launchAngle3, gravityValue)
-- if vx3 then print(string.format("Case 3 Velocity: vx=%.3f, vy=%.3f, vz=%.3f", vx3, vy3, vz3)) else print("Case 3 Failed (as expected)") end

-- Test case: Purely vertical throw
-- local startPos4 = { x = 5, y = 5, z = 0 }
-- local targetPos4 = { x = 5, y = 5, z = 10 } -- Directly above
-- local launchAngle4 = 90
-- local vx4, vy4, vz4 = getInitialThrowVelocity(startPos4, targetPos4, launchAngle4, gravityValue)
-- if vx4 then print(string.format("Case 4 Velocity: vx=%.3f, vy=%.3f, vz=%.3f", vx4, vy4, vz4)) else print("Case 4 Failed") end

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
            askForLocationNbr(player, leader, 3, "teleportOr2", targetPos, alternativePos)
            --triggerClientEvent(player, "startCatchUp", player, leader, 3)
        elseif myPercentage < 0.8 then
            outputChatBox("Use Below 80% of the best score "..inspect(myPercentage))
            askForLocationNbr(player, leader, 5, "teleportOr2", targetPos, alternativePos)
            --triggerClientEvent(player, "startCatchUp", player, leader, 5)
        elseif myPercentage < 0.9 then
            outputChatBox("Use Below 90% of the best score "..inspect(myPercentage))
            askForLocationNbr(player, leader, 7, "teleportOr2", targetPos, alternativePos)
            --triggerClientEvent(player, "startCatchUp", player, leader, 7)
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