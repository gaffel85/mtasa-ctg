local function onDropKey()
    if getGoldCarrier() == localPlayer then
        local vehicle = getPedOccupiedVehicle(localPlayer)
        if not vehicle then return end

        local x, y, z = getElementPosition(vehicle)
        local groundZ = getGroundPosition(x, y, z)
        
        -- Fallback if groundZ is not found (e.g. over water or far from ground)
        if not groundZ then
            groundZ = z - 2
        end

        triggerServerEvent("onPlayerDropGold", resourceRoot, x, y, z, groundZ)
    end
end

local function bindDropKey()
    bindKey("g", "down", onDropKey)
end
addEventHandler("onClientResourceStart", resourceRoot, bindDropKey)
