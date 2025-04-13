local pointsToPlot = {}
local blips = {}
local plotDistance = 60

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

local plotLimit = 5
function plotMainPoints()
    outputServerLog("Plotting main points")
    destroyOldBlips()
    local all = getAllLocations()
    for i, location in ipairs(all) do
        local closeLocations = getLocations(location.x, location.y, location.z, 10)
        if (#closeLocations > plotLimit) then
            local blip = createBlip(location.x, location.y, location.z, 0, 2, 0, 255, 255, 255, 0)
            table.insert(blips, blip)
        end
    end
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
        --saveWholeFileAsJson()
    end
)