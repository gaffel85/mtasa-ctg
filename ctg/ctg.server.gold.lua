local goldSpawns
local bombMarker = nil

function setGoldSpawns(spawns)
    goldSpawns = spawns
end

function spawnNewGold()
    removeOldGold()

    local spawnPoint = goldSpawns[math.random(#goldSpawns)]
    local posX, posY, posZ = coordsFromEdl(spawnPoint)
    local rotX, rotY, rotZ = rotFromEdl(spawnPoint)

    if (bombMarker == nil) then
        bombMarker = createMarker(posX, posY, posZ, "arrow", 2.0, 255, 0, 0)
    end
	createBlip(posX, posY, posZ, 52)
end

function showBlip(carrier)
	destroyElementsByType ("blip")
	createBlipAttachedTo ( carrier, 0 )
end

function removeOldGold()
	destroyElementsByType ("blip")
    destroyMarker()
end

function destroyMarker()
    if (bombMarker ~= nil) then
        destroyElement(bombMarker)
    end
    bombMarker = nil
end

function markerHit(markerHit, matchingDimension)
    if markerHit == bombMarker then
        destroyMarker()
        bombMarker = createMarker(0, 0, 1, "arrow", 2.0, 255, 0, 0)
        attachElements(bombMarker, source, 0, 0, 4)

		showBlip(source)
		setGoldCarrier(source)
        return
    end
end
addEventHandler("onPlayerMarkerHit", getRootElement(), markerHit)
