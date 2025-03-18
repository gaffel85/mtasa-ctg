local locations = {}
local minDistance = 5
local minSpeedForRotation = 50
local filePath = "locations.json"

function hasLocationCloseToForPlayer(x, y, z, player)
    -- check if there is a location close to x, y, z
    for i, location in ipairs(locations) do
        if player == nil or location.player == player then
            if getDistanceBetweenPoints3D(x, y, z, location.x, location.y, location.z) < minDistance then
                return true
            end
        end
    end
    return false
end

function saveLocationForPlayer(player)
    -- save location, rotation, velocity and angular velocity for player
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        return
    end

    if  not isVehicleOnGround(vehicle) then
        return
    end

    local x, y, z = getElementPosition(vehicle)
    if hasLocationCloseToForPlayer(x, y, z, player) then
        return
    end

    local rx, ry, rz = getElementRotation(vehicle)
    local vx, vy, vz = getElementVelocity(vehicle)
    local avx, avy, avz = getElementAngularVelocity(vehicle)
    table.insert(locations, {
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
        player = player
    })
    plotPosition(x, y, z)
end

function plotPosition(x, y, z)
    -- plot a position in the world
    createBlip(x, y, z, 0, 2, 0, 255, 255, 255, 0)
end

function plotAllPositions()
    -- plot all positions in the world
    for i, location in ipairs(locations) do
        plotPosition(location.x, location.y, location.z)
    end
end

function readLocationsFromJsonFile()
    if fileExists(filePath) then
        local file = fileOpen(filePath)
        local size = fileGetSize(file)
        local content = fileRead(file, size)
        fileClose(file)
        local locationsAsArray = fromJSON(content)
        for i, locationAsArray in ipairs(locationsAsArray) do
            local location = {
                x = locationAsArray[1],
                y = locationAsArray[2],
                z = locationAsArray[3],
                rz = locationAsArray[4] or 0,
                ry = 0,
                rx = 0,
                vx = 0,
                vy = 0,
                vz = 0,
                avx = 0,
                avy = 0,
                avz = 0
            }
            table.insert(locations, location)
            plotPosition(location.x, location.y, location.z)
        end
    end
end

function calculateZRotation(vx, vy)
    -- calculate the rotation around Z-axis from velocity vector
    local speed = math.sqrt(vx*vx + vy*vy)
    local speedInKmh = speed * 180
    if speedInKmh < minSpeedForRotation then
        return nil
    end

    local angle = math.deg(math.acos(vx/speed))
    if vy < 0 then
        angle = 360 - angle
    end
    return angle
end

function saveWholeFileAsJson()
    if fileExists(filePath) then
        fileDelete(filePath)
    end

    local file = fileCreate(filePath)

    locationsAsArray = {}
    for i, location in ipairs(locations) do
        table.insert(locationsAsArray, {
            location.x,
            location.y,
            location.z,
            calculateZRotation(location.vx, location.vy),
        })
    end

    local json = toJSON(locationsAsArray)
    fileWrite(file, json)
    fileFlush(file)
    fileClose(file)
end

function appendToFile()
    local file = nil
    if fileExists(filePath) then
        file = fileOpen(filePath)
    else
        file = fileCreate(filePath)
        fileWrite(file, "locations = {\n")
    end

    if file then                                  -- check if it was successfully opened
        fileSetPos( file, fileGetSize( file ) )   -- move position to the end of the file
        for i, location in ipairs(locations) do
            if not location.write then
                
                -- save data in indexed table as array
                local dataAsArray = {
                    location.x,
                    location.y,
                    location.z,
                    location.rx,
                    location.ry,
                    location.rz,
                    location.vx,
                    location.vy,
                    location.vz,
                    location.avx,
                    location.avy,
                    location.avz
                }
                fileWrite(file, "    "..inspect(dataAsArray)..",\n")
                location.write = true
            end
        end
        fileFlush(file)                           -- Flush the appended data into the file.
        fileClose(file)                           -- close the file once we're done with it
    end
end

function closeFile()
    local file = nil
    if fileExists(filePath) then
        file = fileOpen(filePath)
    else
        return
    end

    if file then                                  -- check if it was successfully opened
        fileSetPos( file, fileGetSize( file ) )   -- move position to the end of the file
        fileWrite(file, "}\n")
        fileFlush(file)                           -- Flush the appended data into the file.
        fileClose(file)                           -- close the file once we're done with it
    end
end

function saveLocationsForAllPlayers()
    for i, player in ipairs(getElementsByType("player")) do
        saveLocationForPlayer(player)
    end
end

--onclientresourcestart
addEventHandler("onResourceStart", resourceRoot,
    function()
        readLocationsFromJsonFile()
        setTimer(saveLocationsForAllPlayers, 2000, 100000000)
        setTimer(plotAllPositions, 5000, 1)
        --setTimer(appendToFile, 10000, 100000000)
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function()
        saveWholeFileAsJson()
    end
)