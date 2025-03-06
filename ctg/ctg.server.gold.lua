local goldSpawns
local goldSpawnMarker = nil
local goldCarrierMarker = nil

local goldSpawnBlip = nil
local goldCarrierBlip = nil
local lastGoldSpawn = nil

function setGoldSpawns(spawns)
    goldSpawns = spawns
end

function getLastGoldSpawn()
    return lastGoldSpawn
end

function spawnNewGold()
    local spawnEdl = chooseRandomCloseTo(goldSpawns, meanPositionOfPlayers(), 1000)
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
    local hitMarker = createMarker(posX, posY, posZ - 2, "checkpoint", 2.0, 0, 0, 0, 0, marker)
    local model = createObject(1550, posX, posY , posZ + 2)
    setObjectScale(model, 4.0)
    setElementCollisionsEnabled(model, false)

    setElementParent(model, hitMarker)
    setElementParent(marker, hitMarker)
    return hitMarker
end

function showCarrierBlip(carrier)
	destroyCarrierBlip()
    refreshAllBlips()
	-- goldCarrierBlip = createBlipAttachedTo ( carrier, 0 )
	-- setElementVisibleTo(goldCarrierBlip, carrier, false)
end

function removeOldGold()
	destroySpawnBlip()
    destroyCarrierBlip()
    destroySpawnMarker()
    destroyCarrierMarker()
end

function destroySpawnMarker()
    if (goldSpawnMarker) then
        destroyElement(goldSpawnMarker)
    end
    goldSpawnMarker = nil
end

function destroySpawnBlip()
    refreshAllBlips()
    -- if (goldSpawnBlip) then
    --    destroyElement(goldSpawnBlip)
    -- end
    -- goldSpawnBlip = nil
end

function destroyCarrierBlip()
    refreshAllBlips()
    -- if (goldCarrierBlip) then
    --     destroyElement(goldCarrierBlip)
    -- end
    -- goldCarrierBlip = nil
end

function destroyCarrierMarker()
    if (goldCarrierMarker) then
        destroyElement(goldCarrierMarker)
    end
    goldCarrierMarker = nil
end

function createCarrierMarker(player)
    local marker = createMarker(0, 0, 1, "arrow", 2.0, 255, 0, 0)
    attachElements(marker, player, 0, 0, 4)
    return marker
end

function markerHit(markerHit, matchingDimension)
    if markerHit == goldSpawnMarker then
        destroySpawnMarker()
        destroySpawnBlip()
        goldCarrierMarker = createCarrierMarker(source)

		showCarrierBlip(source)
		goldPickedUp(source)
        return
    end
end
addEventHandler("onPlayerMarkerHit", getRootElement(), markerHit)

function onGoldCarrierChanged(newGoldCarrier, oldGoldCarrier)
    outputChatBox("gold.onGoldCarrierChanged("..inspect(newGoldCarrier)..", "..inspect(oldGoldCarrier)..")")
    destroyCarrierBlip()
    destroyCarrierMarker()
    if (not newGoldCarrier) then
        return
    end

    goldCarrierMarker = createCarrierMarker(newGoldCarrier)
    showCarrierBlip(newGoldCarrier)
end
addEventHandler("goldCarrierChanged", root, onGoldCarrierChanged)
