local locations = {}
local locationsToSend = {}
local minDistance = 5
local minSpeedForRotation = 50
local serverPackageSize = 3

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
        speedMet = speedInKmh >= minSpeedForRotation,
    }
    table.insert(locations, newLocation)
    plotPosition(x, y, z)

    local serverLocation = convertToServerFormat(newLocation)
    table.insert(locationsToSend, serverLocation)

    if (#locationsToSend > serverPackageSize) then
        triggerServerEvent("locationFromClient", resourceRoot, locationsToSend)
        locationsToSend = {}
    end
end

function convertToServerFormat(location)
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

function plotPosition(x, y, z)
    -- plot a position in the world
    createBlip(x, y, z, 0, 2, 120, 90, 255, 255, 0)
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

setTimer(saveLocationForPlayer, 500, 100000000)
outputChatBox("Main file")

addEventHandler( "onClientResourceStart", getRootElement( ),
    function ( startedRes )
        outputChatBox( "Resource started: " .. getResourceName( startedRes ) );
    end
);