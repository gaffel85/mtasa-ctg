--local locations = {}
local locationsNotUsed = {}
local totalRead = 0
local current_id = 1
local quadTree = QuadTree.new(-3500, 3500, -3500, 3500)
local locationsInList = {}
local locationsToInsert = {}
local isAddingFromFile = false

local callback = nil

function reduceLocationsInRepo(callback, cluster_distance, min_cluster_points, max_rotation_diff, astar_distance)
    ClusterReducer:reduceLocations(quadTree, function(reducedLocations)
        clearLocations()
        for i, p in ipairs(reducedLocations) do
            addLocation(p)
            p.new = false
        end
        callback()
    end, cluster_distance, min_cluster_points, max_rotation_diff, astar_distance)
end

function addLocation(location)
    --outputServerLog("Adding location "..inspect(location))
    if not isAddingFromFile then
        location.new = true
    end
    location.id = current_id
    current_id = current_id + 1
    quadTree:add(location)
    table.insert(locationsInList, location)
end

function getAllLocations()
    return locationsInList
end

function clearLocations()
    quadTree:clear()
    locationsNotUsed = {}
    totalRead = 0
    locationsInList = {}
end

function containsLocation(location)
    return quadTree:contains(location)
end


function getLocations(x, y, z, radius)
    return quadTree:queryRadius({ x = x, y = y }, radius)
end

function mapChanged(callback)
    --saveWholeFileAsJson()
    clearLocations()
    addFinishedLoadingLocationsCallback(callback)
    readLocationsFromJsonFile()
end

function addFinishedLoadingLocationsCallback(newCallback)
    callback = newCallback
end

function callCallbacks()
    --outputLog("Callback is "..inspect(callback))
    if not callback then
        return
    end
    callback()
    callback = nil
end

function readLocationsFromJsonFile(useClientFile)
    local filePath = "locations.json"
    if useClientFile then
        filePath = getLastFilePath()
        if not filePath then
            outputLog("No file to read, using default file: locations.json")
            filePath = "locations.json"
        else
            outputLog("Reading from "..filePath)
        end
    end
    if not fileExists(filePath) then
        outputLog("File "..filePath.." does not exist, using default file: locations.json")
        filePath = "locations.json"
    end
    if fileExists(filePath) then

        isAddingFromFile = true

        local file = fileOpen(filePath)
        local size = fileGetSize(file)
        local content = fileRead(file, size)
        totalRead = 0
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
            table.insert(locationsToInsert, location)
        end
        outputLog("Read "..#locationsAsArray.." locations from file")
        insertSomeLocationsAndWait()
        --plotAllPositions()

        --setTimer(plotMainPoints, 5000, 1)
    end
end

function callReducer()
    MeanPosReducer:markStrongLocationsSomeAndWait(callback)
end

function updateNeighborsCnt(location)
    local neighbors = getLocations(location.x, location.y, location.z, MeanPosReducer.neighborsRadius)
    location.neighbors = #neighbors
    for i, neighbor in ipairs(neighbors) do
        if neighbor ~= location then
            neighbor.neighbors = (neighbor.neighbors or 0) + 1
        end
    end
end

function insertingDone()
    outputLog("Read " .. totalRead .. " locations")
    isAddingFromFile = false
    callCallbacks()
end

local totalToInsertThisTime = 2000
function insertSomeLocationsAndWait()
    --take 200 locations from locationsToInsert
    outputLog("Inserting "..totalToInsertThisTime.." locations")

    for i = 1, totalToInsertThisTime do
        if #locationsToInsert == 0 then
            insertingDone()
            return
        end
        local location = table.remove(locationsToInsert, 1)
        if containsLocation(location) then
            outputLog("Read duplicated point, skipping "..inspect(location.x)..", "..inspect(location.y)..", "..inspect(location.z))
        else
            totalRead = totalRead + 1
            if isInsideMapArea(location.x, location.y, location.z) then
                addLocation(location)
                updateNeighborsCnt(location)
                --addPlotPoint(location)
            else
                table.insert(locationsNotUsed, location)
            end
        end 
    end

    if #locationsToInsert > 0 then
        --outputLog("Locations left to insert: "..#locationsToInsert)
        setTimer(insertSomeLocationsAndWait, 1, 1)
    else
        insertingDone()
    end
end

function convertLocationToSaveFormat(location)
    return {
        location.x,
        location.y,
        location.z,
        math.floor(location.rx + 0.5),
        math.floor(location.ry + 0.5),
        math.floor(location.rz + 0.5),
        location.speedMet,
    }
end

local currentFileIdFilePath = "currentFileId.txt"
function getCurrentFileId()
    if fileExists(currentFileIdFilePath) then
        local file = fileOpen(currentFileIdFilePath)
        local size = fileGetSize(file)
        local content = fileRead(file, size)
        fileClose(file)
        outputConsole("Current file id: "..inspect(content))
        -- check if is number
        if tonumber(content) then
            return tonumber(content)
        else
            return 0
        end
    else
        local file = fileCreate(currentFileIdFilePath)
        fileWrite(file, "0")
        fileFlush(file)
        fileClose(file)
        return 0
    end
end

function getNextFilePath()
    local currentFileId = getCurrentFileId()
    local nextFileId = currentFileId + 1
    local filePath = "locations_"..nextFileId..".json"
    if fileExists(filePath) then
        fileDelete(filePath)
    end

    local file = fileOpen(currentFileIdFilePath)
    fileWrite(file, ""..nextFileId)
    fileFlush(file)
    fileClose(file)

    return filePath
end

function getLastFilePath()
    local currentFileId = getCurrentFileId()
    local filePath = "locations_"..currentFileId..".json"
    if fileExists(filePath) then
        return filePath
    end
    return nil
end

function saveWholeFileAsJson()
    local allUsedLocatsion = getAllLocations()
    local totalToSave = #allUsedLocatsion + #locationsNotUsed
    if totalToSave == 0 then
        outputLog("No location to save")
        return
    else
        local newCnt = totalToSave - totalRead
        outputLog("Saving " .. newCnt .. " locations (total: " .. totalToSave .. ")")
    end

    local filePath = getNextFilePath()
    if fileExists(filePath) then
        fileDelete(filePath)
    end

    local file = fileCreate(filePath)

    locationsAsArray = {}
    for i, location in ipairs(allUsedLocatsion) do
        table.insert(locationsAsArray, convertLocationToSaveFormat(location))
    end
    for i, location in ipairs(locationsNotUsed) do
        table.insert(locationsAsArray, convertLocationToSaveFormat(location))
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