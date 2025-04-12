--local locations = {}
local locationsNotUsed = {}
local totalRead = 0
local filePath = "locations.json"
local quadTree = QuadTree.new(-3500, 3500, -3500, 3500)
local locationsInList = {}
local locationsToInsert = {}

local callback = nil

function addLocation(location)
    --outputServerLog("Adding location "..inspect(location))
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
    saveWholeFileAsJson()
    clearLocations()
    addFinishedLoadingLocationsCallback(callback)
    readLocationsFromJsonFile()
end

local function addFinishedLoadingLocationsCallback(newCallback)
    callback = newCallback
end

function callCallbacks()
    callback()
    callback = nil
end

function readLocationsFromJsonFile()
    if fileExists(filePath) then
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
    MeanPosReducer.markStrongLocationsSomeAndWait(callback)
end

local totalToInsertThisTime = 2000
function insertSomeLocationsAndWait()
    --take 200 locations from locationsToInsert
    outputLog("Inserting "..totalToInsertThisTime.." locations")

    for i = 1, totalToInsertThisTime do
        if #locationsToInsert == 0 then
            outputLog("Read " .. totalRead .. " locations")
            callReducer()
            return
        end
        local location = table.remove(locationsToInsert, 1)
        if containsLocation(location) then
            outputLog("Read duplicated point, skipping "..inspect(location.x)..", "..inspect(location.y)..", "..inspect(location.z))
        else
            totalRead = totalRead + 1
            if isInsideMapArea(location.x, location.y, location.z) then
                addLocation(location)
                --addPlotPoint(location)
            else
                table.insert(locationsNotUsed, location)
            end
        end 
    end

    if #locationsToInsert > 0 then
        --outputLog("Locations left to insert: "..#locationsToInsert)
        setTimer(insertSomeLocationsAndWait, 1, 1, )
    else
        outputLog("Read " .. totalRead .. " locations")
        callReducer()
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