local goldSpawns
local goldMarker = nil

function setGoldSpawns(spawns)
    goldSpawns = spawns
end

function spawnNewGold()
    removeOldGold()

    local spawnPoint = goldSpawns[math.random(#goldSpawns)]
    local posX, posY, posZ = coordsFromEdl(spawnPoint)
    local rotX, rotY, rotZ = rotFromEdl(spawnPoint)

    if (goldMarker == nil) then
        goldMarker = createMarker(posX, posY, posZ, "arrow", 2.0, 255, 0, 0)
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
    if (goldMarker ~= nil) then
        destroyElement(goldMarker)
    end
    goldMarker = nil
end

function markerHit(markerHit, matchingDimension)
    if markerHit == goldMarker then
        destroyMarker()
        goldMarker = createMarker(0, 0, 1, "arrow", 2.0, 255, 0, 0)
        attachElements(goldMarker, source, 0, 0, 4)

		showBlip(source)
		setGoldCarrier(source)
        return
    end
end
addEventHandler("onPlayerMarkerHit", getRootElement(), markerHit)
