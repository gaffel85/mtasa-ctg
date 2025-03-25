local locations = {}
local locationsToSend = {}
local lastBlips = {}
local maxBlips = 5
local minDistance = 5
local minSpeedForRotation = 50
local serverPackageSize = 3
local maxLocactions = 500

function hasLocationCloseToForPlayer(x, y, z)
    -- check if there is a location close to x, y, z
    for i, location in ipairs(locations) do
        if getDistanceBetweenPoints3D(x, y, z, location.x, location.y, location.z) < minDistance then
            return true
        end
    end
    return false
end

function isAllWheelsOnGround(vehicle)
    return isVehicleWheelOnGround(vehicle, 0) and isVehicleWheelOnGround(vehicle, 1) and isVehicleWheelOnGround(vehicle, 2) and isVehicleWheelOnGround(vehicle, 3)
end

function  getVehicleGroundPos(vehicle)
    local x, y, z = getElementPosition(vehicle)
    local ground = getGroundPosition (x,y,z)
    return x, y, ground
end

function saveLocationForPlayer()
    local player = localPlayer
    -- save location, rotation, velocity and angular velocity for player
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        return
    end

    if not isAllWheelsOnGround(vehicle) then
        return
    end

    local x, y, z = getVehicleGroundPos(vehicle)
    if hasLocationCloseToForPlayer(x, y, z) then
        return
    end

    local rx, ry, rz = getElementRotation(vehicle)
    local vx, vy, vz = getElementVelocity(vehicle)
    -- speed in km/h using vx, vy, vz
    local speed = math.sqrt(vx*vx + vy*vy + vz*vz)
    local speedInKmh = speed * 180
    local rotZ = calculateZRotation(vx, vy)

    --outputChatBox(""..rz.." "..inspect(rotZ).." "..speedInKmh)

    local avx, avy, avz = getElementAngularVelocity(vehicle)
    local newLocation = {
        x = x,
        y = y,
        z = z,
        rx = rx,
        ry = ry,
        rz = rz,
        vx = vx,
        vy = vy,
        vz = vz,
        avx = avx,
        avy = avy,
        avz = avz,
        timestamp = getRealTime().timestamp,
        speedMet = speedInKmh >= minSpeedForRotation,
    }
    table.insert(locations, newLocation)
    plotPosition(x, y, z)

    local serverLocation = convertToCompactServerFormat(newLocation)
    table.insert(locationsToSend, serverLocation)

    if (#locationsToSend > serverPackageSize) then
        triggerServerEvent("locationFromClient", resourceRoot, locationsToSend)
        locationsToSend = {}
    end

    if (#locations > maxLocactions) then
		table.remove(locations, 1)
	end
end

function convertToCompactServerFormat(location)
    return {
        location.x,
        location.y,
        location.z,
        location.rx,
        location.ry,
        location.rz,
        location.speedMet
    }
end

function convertToServerFormat(location)
    return {
        x = location.x,
        y = location.y,
        z = location.z,
        rx = location.rx,
        ry = location.ry,
        rz = location.rz,
        vx = location.vx,
        vy = location.vy,
        vz = location.vz,
        vrx = location.avx,
        vry = location.avy,
        vrz = location.avz,
    }
end

function plotPosition(x, y, z)
    -- plot a position in the world
    --local blip = createBlip(x, y, z, 0, 2, 120, 90, 255, 255, 0)
    -- remove oldest blip if more than maxBlips
   -- if #lastBlips > maxBlips then
    --    local oldestBlip = table.remove(lastBlips, 1)
    --    destroyElement(oldestBlip)
    --end
    --table.insert(lastBlips, blip)
end

function plotAllPositions()
    -- plot all positions in the world
    for i, location in ipairs(locations) do
        plotPosition(location.x, location.y, location.z)
    end
end

function calculateZRotation(vx, vy)
    -- calculate the rotation around Z-axis from velocity vector
    local speed = math.sqrt(vx*vx + vy*vy)

    local angle = math.deg(math.acos(vx/speed)) - 90
    if vy < 0 then
        angle = 360 - angle
    end
    return angle
end

function findLocationClosestToTimeAgo(timeAgo)
    outputConsole("findLocationClosestToTimeAgo "..timeAgo)

    if (#locations == 0) then
        return nil
    end
    local closestLocation = locations[#locations]
    outputConsole("closestLocation "..inspect(closestLocation.timestamp))
    local closestTime = math.abs(getRealTime().timestamp - closestLocation.timestamp - timeAgo)
    -- iterate backwards from the last location
    for i = #locations, 1, -1 do
        local location = locations[i]
        local time = getRealTime().timestamp - location.timestamp
        local locationTimeAgo = math.abs(time - timeAgo)
        if locationTimeAgo < closestTime then
            closestTime = locationTimeAgo
            closestLocation = location
        end
    end
    return closestLocation
end

setTimer(saveLocationForPlayer, 500, 100000000)
outputChatBox("Main file")

addEvent("reportLastTransform", true)
addEventHandler("reportLastTransform", resourceRoot, function(index, param1, param2, param3, param4, param5, param6)
	outputChatBox("reportLastTransform "..inspect(index).." "..inspect(param1).." "..inspect(param2).." "..inspect(param3))
    outputChatBox("1")
	if (#locations == 0 or #locations < index) then
        outputChatBox("2")
        outputChatBox("Too few locations "..#locations.." "..index)
		return
	end
    outputChatBox("3")
	local transform = locations[#locations - index]
    if not transform then
        outputChatBox("Could not find location at index "..index)
        return
    end
    local serverTransform = convertToServerFormat(transform)
    outputChatBox("Transform to send  "..inspect(serverTransform))
	triggerServerEvent("reportTransform", resourceRoot, serverTransform, param1, param2, param3, param4, param5, param6)
end)

addEvent("reportLastTransformTimeAgo", true)
addEventHandler("reportLastTransformTimeAgo", resourceRoot, function(timeAgo, param1, param2, param3, param4, param5, param6)
	outputChatBox("reportLastTransformTimeAgo "..inspect(timeAgo).." "..inspect(param1)..' '..inspect(param2)..' '..inspect(param3)..' '..inspect(param4)..' '..inspect(param5)..' '..inspect(param6))
	if (#locations == 0) then
        outputChatBox("Too few locations "..#locations)
		return
	end
	local transform = findLocationClosestToTimeAgo(timeAgo)
	if not transform then
		outputChatBox("No location found close to time ago "..timeAgo)
		return
	end
    local serverTransform = convertToServerFormat(transform)
    outputConsole("Transform to send "..inspect(serverTransform))
	triggerServerEvent("reportTransform", resourceRoot, serverTransform, param1, param2, param3, param4, param5, param6)
end)

addEventHandler( "onClientResourceStart", getRootElement( ),
    function ( startedRes )
        outputChatBox( "Resource started: " .. getResourceName( startedRes ) );
    end
);

addEventHandler( "onClientResourceStop", getRootElement( ),
    function ( startedRes )
        outputChatBox( "Resource stopped: " .. getResourceName( startedRes ) );
    end
);