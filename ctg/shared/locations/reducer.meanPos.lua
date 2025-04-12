MeanPosReducer = {
    callbacks = {},
    neighborsRadius = 10,
    totalToMarkAtTime = 500
}

local function MeanPosReducer:addCallback(callback)
    table.insert(self.callbacks, callback)
end

function MeanPosReducer:callCallbacks()
    for i, callback in ipairs(self.callbacks) do
        callback()
    end
    self.callbacks = {}
end

function MeanPosReducer:reduceLocations(allLocations, callback)
    --add callack
    self:addCallback(callback)
    markStrongLocationsSomeAndWait()
end

function markStrongLocationsSomeAndWait(index)
    local locIndex = index or 1
    outputLog("Start marking at "..locIndex)
    -- loop over 500 locations and perform an operation, if more setTimer
    for i = locIndex, locIndex + MeanPosReducer.totalToMarkAtTime - 1 do
        if i > #locationsInList then
            outputLog("Index "..i.." is out of bounds, total: "..#locationsInList)
            eleminateSomeLocationsAndWait()
            return
        end
        local location = locationsInList[i]
        local neighbors = getLocations(location.x, location.y, location.z, MeanPosReducer.neighborsRadius)
        local meanX, meanY = meanXYPos(neighbors)
        local distance = getDistanceBetweenPoints2D(location.x, location.y, meanX, meanY)
        location.distance = distance
        location.neighbors = #neighbors
    end

    local lastIndx = locIndex + MeanPosReducer.totalToMarkAtTime - 1
    if lastIndx < #locationsInList then
        --outputLog("Locations left to mark")
        setTimer(markStrongLocationsSomeAndWait, 1, 1, lastIndx + 1)
    else
        outputLog("Marked " .. totalRead .. " locations")
        eleminateSomeLocationsAndWait()
    end
end

function meanValueOfNeighbors(locations)
    local total = 0
    for i, location in ipairs(locations) do
        total = total + location.neighbors
    end
    return total / #locations
end

function meanXYPos(locations)
    local totalX = 0
    local totalY = 0
    for i, location in ipairs(locations) do
        totalX = totalX + location.x
        totalY = totalY + location.y
    end
    return totalX / #locations, totalY / #locations
end

function meanDistance(neighbors)
    local total = 0
    for i, location in ipairs(neighbors) do
        total = total + location.distance
    end
    return total / #neighbors
end

local totalRemoved = 0
local removePercentage = 0.8
local totalToEleminateAtTime = 500
function eleminateSomeLocationsAndWait(index)
    local locIndex = index or 1
    outputLog("Start eleminating at "..locIndex)
    -- loop over 500 locations and perform an operation, if more setTimer
    for i = locIndex, locIndex + totalToEleminateAtTime - 1 do
        if i > #locationsInList then
            outputLog("Index "..i.." is out of bounds, total: "..#locationsInList..", removed: "..totalRemoved)
            MeanPosReducer.callCallbacks()
            return
        end
        local location = locationsInList[i]
        local neighbors = getLocations(location.x, location.y, location.z, MeanPosReducer.neighborsRadius)
        local meanDistance = meanDistance(neighbors)
        if #neighbors > 5 and location.distance * removePercentage > meanDistance then
            location.weak = true
            totalRemoved = totalRemoved + 1
        end
    end

    local lastIndx = locIndex + totalToEleminateAtTime - 1
    if lastIndx < #locationsInList then
        --outputLog("Locations left to eleminate")
        setTimer(eleminateSomeLocationsAndWait, 1, 1, lastIndx + 1)
    else
        outputLog("Eleminated " .. totalRead .. " locations, removed: " .. totalRemoved)
        MeanPosReducer.callCallbacks()
    end
end