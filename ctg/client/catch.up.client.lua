
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

function teleportPlayerAndSetCameraToFollow(player)
    local x, y, z = getCameraMatrix()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        setElementPosition(vehicle, x, y, z)
    else
        setElementPosition(player, x, y, z)
    end
    setCameraTarget(player)
end

local targetLocation = nil
local throwTimer = nil
local velocityFactor = 5
local initialVelocity = 1.5
function throwPlayerTo(player, leader, stepsBehind)
    targetLocation = nil
    if throwTimer and isTimer(throwTimer) then
        kill(throwTimer)
        throwTimer = nil
    end
    -- get last leader position - stepsbehind
    if (not leader) then
        outputConsole("No leader")
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputConsole("Player is not in a vehicle")
        return
    end
    local allLeaderLocations = getLocationsForPlayer(leader)
    if (#allLeaderLocations == 0) then
        outputConsole("No leader locations")
        return
    end

    -- sort them on id with highest first
    table.sort(allLeaderLocations, function(a, b) return a.id > b.id end)
    if stepsBehind > #allLeaderLocations then
        targetLocation = allLeaderLocations[1]
    else
        targetLocation = allLeaderLocations[stepsBehind]
    end

    setElementVelocity(vehicle, 0, 0, initialVelocity)
    throwTimer = setTimer(function()
        if (targetLocation) then
            local x, y, z = getElementPosition(vehicle)
            -- get a position between x,y,z and targetLocation 50m from x, y, z
            local distance2d = getDistanceBetweenPoints2D(x, y, targetLocation.x, targetLocation.y)
            if distance2d < 20 then
                outputChatBox("Target location close")
                local vectorFromPosToTarget = {targetLocation.x - x, targetLocation.y - y, targetLocation.z - z}
                setElementVelocity(vehicle, vectorFromPosToTarget[1] * velocityFactor, vectorFromPosToTarget[2] * velocityFactor, vectorFromPosToTarget[3] * velocityFactor)
            else
                local factor = 20
                local vectorFromPosToTarget = {targetLocation.x - x, targetLocation.y - y, 0}
                local vectorFromPosToTargetNormalized = {vectorFromPosToTarget[1] / distance2d, vectorFromPosToTarget[2] / distance2d, 0}
                local newX, newY, newZ = x + vectorFromPosToTarget[1] * factor, y + vectorFromPosToTarget[2] * factor, z
                if isLineOfSightClear(x, y, z, newX, newY, newZ) then
                    --setElementPosition(vehicle, newX, newY, newZ)
                    setElementVelocity(vehicle, vectorFromPosToTargetNormalized[1] * velocityFactor, vectorFromPosToTargetNormalized[2] * velocityFactor, initialVelocity / 5)
                else
                    setElementVelocity(vehicle, 0, 0, initialVelocity)
                end
            end
        else 
            killTimer(throwTimer)
            throwTimer = nil
        end
    end, 2000, 0)
end

function flyCameraTo(player, leader, stepsBehind)
    if (not leader) then
        outputConsole("No leader")
        return
    end
    local allLeaderLocations = getLocationsForPlayer(leader)
    if (#allLeaderLocations == 0) then
        outputConsole("No leader locations")
        return
    end

    -- sort them on id with highest first
    table.sort(allLeaderLocations, function(a, b) return a.id > b.id end)

    local x, y, z = getElementPosition(player)
    -- find the leaderLocation that is closest to the player
    local closestLeadLocationIndex = 1
    local closestLeaderLocation = allLeaderLocations[closestLeadLocationIndex]
    local closestLeaderLocationDistance = getDistanceBetweenPoints3D(x, y, z, closestLeaderLocation.x, closestLeaderLocation.y, closestLeaderLocation.z)
    for i, location in ipairs(allLeaderLocations) do
        if getDistanceBetweenPoints3D(x, y, z, location.x, location.y, location.z) < closestLeaderLocationDistance then
            closestLeadLocationIndex = i
            closestLeaderLocation = location
            closestLeaderLocationDistance = getDistanceBetweenPoints3D(x, y, z, location.x, location.y, location.z)
        end
    end

    outputConsole("Closest leader location: "..inspect(closestLeadLocationIndex) .. " " .. inspect(closestLeaderLocation))

    local leaderLocations = {}
    for i = closestLeadLocationIndex, #allLeaderLocations - stepsBehind - 1 do
        local loc = allLeaderLocations[i]
        table.insert(leaderLocations, { x = loc.x, y = loc.y, z = loc.z + 3 })
    end

    outputConsole("Leader locations: "..inspect(#leaderLocations))

    cameraFly(leaderLocations, player, 360, function()
        outputChatBox("Catch up completed for "..inspect(getPlayerName(player)))
        teleportPlayerAndSetCameraToFollow(player)
    end, { lookAtSmoothFactor = 0.08 })
end

addEventHandler("startCatchUp", getRootElement(), function (leader, stepsBehind)
    local player = localPlayer
    outputChatBox("Will catch up "..inspect(getPlayerName(player)).." to "..inspect(getPlayerName(leader)).." in "..inspect(stepsBehind).." steps")
    throwPlayerTo(player, leader, stepsBehind)
end)

addEventHandler("stopCatchUp", getRootElement(), function ()
    local player = localPlayer
    outputChatBox("Catch up stopped for "..inspect(getPlayerName(player)))
end)