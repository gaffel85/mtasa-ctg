local hideouts
local hidoutMarker = nil
local hidoutBlip = nil

function setHideouts(spawns)
    hideouts = spawns
end

function spawnNewHideout()
    outputChatBox("3")
    removeOldHideout()

    local spawnPoint = hideouts[math.random(#hideouts)]
    local posX, posY, posZ = coordsFromEdl(spawnPoint)
    local rotX, rotY, rotZ = rotFromEdl(spawnPoint)

    if (hideoutMarker == nil) then
        hideoutMarker = createMarker(posX, posY, posZ, "checkpoint", 2.0, 255, 0, 0)
    end
    outputChatBox("4")
	hideoutBlip = createBlip(posX, posY, posZ, 52)
end

function removeOldHideout()
	destroyBlip()
    destroyMarker()
end

function destroyMarker()
    if (hideoutMarker ~= nil) then
        destroyElement(hideoutMarker)
    end
    hideoutMarker = nil
end

function destroyBlip()
    if (hideoutBlip ~= nil) then
        destroyElement(hideoutBlip)
    end
    hideoutBlip = nil
end

function markerHit(markerHit, matchingDimension)
    outputChatBox("5")
    if source == getGoldCarrier() and markerHit == hideoutMarker then
        outputChatBox("6")
        removeOldHideout()
        goldDelivered(source)
    end
end
addEventHandler("onPlayerMarkerHit", getRootElement(), markerHit)
