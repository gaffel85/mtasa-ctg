local goldSpawns
local goldSpawnMarker = nil
local goldCarrierMarker = nil

local goldSpawnBlip = nil
local goldCarrierBlip = nil

function setGoldSpawns(spawns)
    goldSpawns = spawns
end

function spawnNewGold()
    removeOldGold()

    local spawnPoint = goldSpawns[math.random(#goldSpawns)]
    local posX, posY, posZ = coordsFromEdl(spawnPoint)
    local rotX, rotY, rotZ = rotFromEdl(spawnPoint)

    if (goldSpawnMarker == nil) then
        goldSpawnMarker = createMarker(posX, posY, posZ, "arrow", 2.0, 255, 0, 0)
    end
    destroySpawnBlip()
    goldSpawnBlip = createBlip(posX, posY, posZ, 52)
end

function showCarrierBlip(carrier)
	destroyCarrierBlip()
	goldCarrierBlip = createBlipAttachedTo ( carrier, 0 )
	setElementVisibleTo(goldCarrierBlip, carrier, false)
end

function removeOldGold()
	destroySpawnBlip()
    destroyCarrierBlip()
    destroySpawnMarker()
    destroyCarrierMarker()
end

function destroySpawnMarker()
    if (goldSpawnMarker ~= nil) then
        destroyElement(goldSpawnMarker)
    end
    goldSpawnMarker = nil
end

function destroySpawnBlip()
    if (goldSpawnBlip ~= nil) then
        destroyElement(goldSpawnBlip)
    end
    goldSpawnBlip = nil
end

function destroyCarrierBlip()
    if (goldCarrierBlip ~= nil) then
        destroyElement(goldCarrierBlip)
    end
    goldCarrierBlip = nil
end

function destroyCarrierMarker()
    if (goldCarrierMarker ~= nil) then
        destroyElement(goldCarrierMarker)
    end
    goldCarrierMarker = nil
end

function markerHit(markerHit, matchingDimension)
    if markerHit == goldSpawnMarker then
        destroySpawnMarker()
        destroySpawnBlip()
        goldCarrierMarker = createMarker(0, 0, 1, "arrow", 2.0, 255, 0, 0)
        attachElements(goldCarrierMarker, source, 0, 0, 4)

		showCarrierBlip(source)
		setGoldCarrier(source)
        return
    end
end
addEventHandler("onPlayerMarkerHit", getRootElement(), markerHit)
