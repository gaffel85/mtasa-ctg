--local locations = {}
local pointsToPlot = {}
local blips = {}
local plotDistance = 60
local filePath = "locations.json"
local quadTree = QuadTree.new(-3500, 3500, -3500, 3500)

function addLocation(location)
    --outputServerLog("Adding location "..inspect(location))
    quadTree:add(location)
end

function getAllLocations()
    local quadLocations = quadTree:getAll()
    return quadLocations
end

function clearLocations()
    quadTree:clear()
end

function getLocations(x, y, z, radius)
    return quadTree:queryRadius({ x = x, y = y }, radius)
end

function plotPosition(x, y, z)
    -- plot a position in the world
    --local blip = createBlip(x, y, z, 0, 2, 0, 255, 255, 255, 0)
    --table.insert(blips, blip)
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
    local players = getElementsByType("player")
    if #players == 0 then
        return
    end
    local firstPlayer = players[1]
    local x, y, z = getElementPosition(firstPlayer)
    -- plot all positions in the world
    for i, location in ipairs(pointsToPlot) do
        if getDistanceBetweenPoints3D(x, y, z, location.x, location.y, location.z) < 500 then
            plotPosition(location.x, location.y, location.z)
        end
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

function mapChanged()
    saveWholeFileAsJson()
    clearLocations()
    readLocationsFromJsonFile()
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

            if isInsideMapArea(location.x, location.y, location.z) then
                addLocation(location)
                addPlotPoint(location)
            end
        end
        plotAllPositions()
    end
end

function saveWholeFileAsJson()
    if #getAllLocations() then
        outputServerLog("No location to save")
        return
    end

    if fileExists(filePath) then
        fileDelete(filePath)
    end

    local file = fileCreate(filePath)

    locationsAsArray = {}
    for i, location in ipairs(getAllLocations()) do
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

function getRotatedLocationsOrOther(locations, minNumbers, randomOrder)
    local randomize = randomOrder or false
    local locationsWithRot = {}
    local locationsWithoutRot = {}
    for i, location in ipairs(locations) do
        if location.speedMet then
            table.insert(locationsWithRot, location)
        else
            table.insert(locationsWithoutRot, location)
        end
    end

    if randomize then
        shuffle(locationsWithRot)
        shuffle(locationsWithoutRot)
    end

    -- if locationWithRot is fewere than minNumbers, add locationsWithoutRot to meat minNumbers. Handle the case where locationsWithoutRot is too few
    while #locationsWithRot < minNumbers do
        if #locationsWithoutRot == 0 then
            break
        end
        table.insert(locationsWithRot, table.remove(locationsWithoutRot, 1))
    end


    return locationsWithRot
end

function elementWisePos(location)
    return location.x, location.y, location.z, location.rx, location.ry, location.rz
end

function getRandomRotatedLocationOrOther(locations, minNumbers)
-- return pos that has a non 0 rotation
    local locationsWithRot = getRotatedLocationsOrOther(locations, minNumbers)
    
    local randomLoc = locationsWithRot[1]
    if randomLoc then
        return elementWisePos(randomLoc)
    end

    local location = getAllLocations()[1]
    if not location then
        return 0,0,0,0,0,0
    end
    return elementWisePos(location)
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
            addLocation(location)
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
        clearLocations()
        blips = {}
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