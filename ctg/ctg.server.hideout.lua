local hideouts
local hidoutMarker = nil

function setHideouts(spawns)
    hideouts = spawns
end

function spawnNewHideout()
    removeOldHideout()

    local spawnPoint = hideouts[math.random(#hideouts)]
    local posX, posY, posZ = coordsFromEdl(spawnPoint)
    local rotX, rotY, rotZ = rotFromEdl(spawnPoint)

    if (hideoutMarker == nil) then
        hideoutMarker = createMarker(posX, posY, posZ, "arrow", 2.0, 255, 0, 0)
    end
	createBlip(posX, posY, posZ, 52)
end

function showBlip(carrier)
	destroyElementsByType ("blip")
	createBlipAttachedTo ( carrier, 53 )
end

function removeOldHideout()
	destroyElementsByType ("blip")
    destroyMarker()
end

function destroyMarker()
    if (hideoutMarker ~= nil) then
        destroyElement(hideoutMarker)
    end
    hideoutMarker = nil
end

function markerHit(markerHit, matchingDimension)
    if markerHit == hideoutMarker then
        removeOldHideout()
        return
    end
end
addEventHandler("onPlayerMarkerHit", getRootElement(), markerHit)
