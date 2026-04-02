local goldSpawns
local goldSpawnMarker = nil
local goldCarrierMarker = nil
local activeGoldObject = nil

local goldSpawnBlip = nil
local goldCarrierBlip = nil
local lastGoldSpawn = nil
local nextGoldEdl = nil

local spawnTimer = nil
local countDownTimer = nil
local coundownTextKey = 3242554


function setGoldSpawns(spawns)
    goldSpawns = spawns
end

function getLastGoldSpawn()
    return lastGoldSpawn
end

function clearLastGoldSpawn()
    lastGoldSpawn = nil
end

function prepareNextGold()
    nextGoldEdl = chooseRandomCloseToByLimits(goldSpawns, meanPositionOfPlayers(), getConst().goldSpawnDistance, getConst().goldSpawnSafeDistance, getConst().goldSpawnMinDistance)
end

function scheduleNextGold(countdown)
    spawnTimer = setTimer(spawnNewGold, countdown * 1000, 1)
    countDownTextForAll(countdown, coundownTextKey, "Gold will spawn in", nil, nil, 0.5, 0.4, 88, 255, 120, 255, 3)
end

function spawnNewGold()
    local spawnEdl = nextGoldEdl
    if not spawnEdl then
        spawnEdl = chooseRandomCloseToByLimits(goldSpawns, meanPositionOfPlayers(), getConst().goldSpawnDistance, getConst().goldSpawnSafeDistance, getConst().goldSpawnMinDistance)
    end
    nextGoldEdl = nil
    
    local posX, posY, posZ = coordsFromEdl(spawnEdl)
    lastGoldSpawn = {
        edl = spawnEdl,
        x = posX,
        y = posY,
        z = posZ,
        desc = getElementData(spawnEdl, "desc")
    }
    spawnGoldAtTransform(posX, posY, posZ)
end

function spawnGoldAtTransform(posX, posY, posZ)
    removeOldGold()
    if (goldSpawnMarker == nil) then
        goldSpawnMarker = createGold(posX, posY, posZ)
    end
    lastGoldSpawn.x = posX
    lastGoldSpawn.y = posY
    lastGoldSpawn.z = posZ
    refreshAllBlips()
    -- goldSpawnBlip = createBlip(posX, posY, posZ, 52)
end

function createGold(posX, posY, posZ)
    local marker = createMarker(posX, posY, posZ + 6, "arrow", 2.0, 255, 0, 0)
    local hitMarker = createMarker(posX, posY, posZ - 2, "checkpoint", 2.0, 0, 0, 0, 0, getRootElement())
    setElementVisibleTo(blip, getRootElement(), false)
    
    -- Create the persistent gold object
    if not activeGoldObject or not isElement(activeGoldObject) then
        activeGoldObject = createObject(1212, posX, posY, posZ + 1.5)
        setElementData(activeGoldObject, "isGold", true)
        setElementCollisionsEnabled(activeGoldObject, false)
    else
        detachElements(activeGoldObject)
        setElementPosition(activeGoldObject, posX, posY, posZ + 1.5)
    end

    triggerClientEvent("onClientSetGoldElement", root, activeGoldObject)
    setObjectScale(activeGoldObject, 6.0)

    setElementParent(marker, hitMarker)
    return hitMarker
end

function removeOldGold()
	destroySpawnBlip()
    destroySpawnMarker()
    destroyCarrierMarker()
    refreshAllBlips()
end

function destroySpawnMarker()
    if (goldSpawnMarker) then
        destroyElement(goldSpawnMarker)
    end
    goldSpawnMarker = nil
    -- Detach gold object if it was attached to the marker
    if activeGoldObject and isElement(activeGoldObject) then
        detachElements(activeGoldObject)
    end
end

function destroySpawnBlip()
    refreshAllBlips()
end

function destroyCarrierMarker()
    if (goldCarrierMarker) then
        destroyElement(goldCarrierMarker)
    end
    goldCarrierMarker = nil
end

function getVehicleZOffset(vehicle)
    if not vehicle then return 4 end
    local radius, x1, y1, z1, x2, y2, z2 = getVehicleSizeData(vehicle)
    return z2 + 0.5
end
function createCarrierMarker(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then return nil end

    local zOffset = getVehicleZOffset(vehicle)
    local marker = createMarker(0, 0, 0, "arrow", 2.0, 255, 0, 0)
    setElementData(marker, "isGoldCarrierMarker", true)

    attachElements(marker, vehicle, 0, 0, zOffset + 4.0)

    -- Also attach the gold bar if it exists
    -- Also attach the gold bar if it exists
    if activeGoldObject and isElement(activeGoldObject) then
        detachElements(activeGoldObject)
        attachElements(activeGoldObject, vehicle, 0, 0, zOffset)
    end

    return marker
end

function markerHit(markerHit, matchingDimension)
    if markerHit == goldSpawnMarker then
        -- Don't destroy activeGoldObject, just detach it from whatever it might be
        destroySpawnMarker()
        destroySpawnBlip()
		goldPickedUp(source)
        refreshAllBlips()
        return
    end
end
addEventHandler("onPlayerMarkerHit", getRootElement(), markerHit)

function onGoldCarrierChanged(newGoldCarrier, oldGoldCarrier)
    destroyCarrierMarker()
    handlePowersForGoldCarrierChanged(newGoldCarrier, oldGoldCarrier)
    if (not newGoldCarrier) then
        -- If no new carrier, make sure gold is detached
        if activeGoldObject and isElement(activeGoldObject) then
            detachElements(activeGoldObject)
        end
        return
    end

    goldCarrierMarker = createCarrierMarker(newGoldCarrier)
    refreshAllBlips()
end
addEventHandler("goldCarrierChanged", root, onGoldCarrierChanged)

addEvent("onClientRequestGoldElement", true)
addEventHandler("onClientRequestGoldElement", root, function()
    if activeGoldObject and isElement(activeGoldObject) then
        triggerClientEvent(client, "onClientSetGoldElement", root, activeGoldObject)
    end
end)

-- onResourceStart clear timers
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), function()
    if (spawnTimer) then
        killTimer(spawnTimer)
    end
    if (countDownTimer) then
        killTimer(countDownTimer)
    end
end)
