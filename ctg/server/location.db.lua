local locations = {}
local pointsToPlot = {}
local blips = {}
local plotDistance = 30
local filePath = "locations.json"

function plotPosition(x, y, z)
    -- plot a position in the world
    local blip = createBlip(x, y, z, 0, 2, 0, 255, 255, 255, 0)
    table.insert(blips, blip)
end

function destroyOldBlips()
    for i, blip in ipairs(blips) do
        if isElement(blip) then
            destroyElement(blip)
        end
    end
    blips = {}
end

function plotAllPositions()
    destroyOldBlips()
    -- plot all positions in the world
    for i, location in ipairs(pointsToPlot) do
        plotPosition(location.x, location.y, location.z)
    end
end

function addPlotPoint(newLocation)
    local x = newLocation.x
    local y = newLocation.y
    local z = newLocation.z
    local found = false
    for j, point in ipairs(pointsToPlot) do
        if getDistanceBetweenPoints3D(x, y, z, point.x, point.y, point.z) < plotDistance then
            --outputServerLog("To close, skipping")
            found = true
        end
    end
    if not found then
        table.insert(pointsToPlot, newLocation)
    end
end

function findPointsToPlot(newPoints)
    for i, newLocation in ipairs(newPoints) do
        addPlotPoint(newLocation)
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
                ry = locationAsArray[4] or 0,
                rx = locationAsArray[5] or 0,
                rz = locationAsArray[6] or 0,
                speedMet = locationAsArray[7] or false,
            }
            table.insert(locations, location)
            addPlotPoint(location)
        end
        plotAllPositions()
    end
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
            math.floor(location.rx + 0.5),
            math.floor(location.ry + 0.5),
            math.floor(location.rz + 0.5),
            location.speedMet,
        })
    end

    local json = toJSON(locationsAsArray)
    fileWrite(file, json)
    fileFlush(file)
    fileClose(file)
end

function getPosAndRot()
    -- return pos that has a non 0 rotation
    for i, location in ipairs(locations) do
        if location.rz ~= 0 then
            return location.x, location.y, location.z, location.rx, location.ry, location.rz
        end
    end

    outputServerLog("Failed to find rotated pos")
    local location = locations[1]
    if not location then
        return 0,0,0,0,0,0
    end
    return location.x, location.y, location.z, location.rx, location.ry, location.rz
end

addEvent("locationFromClient", true)
addEventHandler("locationFromClient", resourceRoot,
    function(newLocations)
        for i, locationAsArray in ipairs(newLocations) do
            local location = {
                x = locationAsArray[1],
                y = locationAsArray[2],
                z = locationAsArray[3],
                ry = locationAsArray[4] or 0,
                rx = locationAsArray[5] or 0,
                rz = locationAsArray[6] or 0,
                speedMet = locationAsArray[7] or false,
            }
            table.insert(locations, location)
            addPlotPoint(location)
            --createMarker(location.x, location.y, location.z, "corona")
        end
        plotAllPositions()
        --saveLocationForPlayer(client)
    end
)

--onclientresourcestart
addEventHandler("onResourceStart", resourceRoot,
    function()
        locations = {}
        blips = {}
        readLocationsFromJsonFile()
        --setTimer(saveLocationsForAllPlayers, 2000, 100000000)
        setTimer(plotAllPositions, 5000, 1)
        --setTimer(appendToFile, 10000, 100000000)
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function()
        destroyOldBlips()
        saveWholeFileAsJson()
    end
)