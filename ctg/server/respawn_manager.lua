local storedVelocity = {}
local storedAngularVelocity = {}
local isRewinding = {}

addEvent("onRespawnOnDamageTeleport", true)
addEventHandler("onRespawnOnDamageTeleport", resourceRoot, function(x, y, z, rx, ry, rz, vx, vy, vz, avx, avy, avz, gx, gy, gz)
    isRewinding[client] = true
    setElementData(client, "isRewinding", true)
    
    -- Drop gold if carrier
    local currentCarrier = getGoldCarrier()
    if client == currentCarrier then
        outputServerLog("[CTG-REWIND] Player " .. getPlayerName(client) .. " is carrier, dropping gold.")
        local px, py, pz = getElementPosition(client)
        -- Use provided ground position if available, otherwise fallback to current position
        local sx, sy, sz = gx or px, gy or py, gz or pz
        clearGoldCarrier()
        spawnGoldAtTransform(sx, sy, sz)
        refreshAllBlips()
        
        -- Prevent immediate re-pickup
        setElementData(client, "blockGoldPickup", true)
        setTimer(function(p)
            if isElement(p) then
                setElementData(p, "blockGoldPickup", false)
            end
        end, 1500, 1, client)
    end

    local vehicle = getPedOccupiedVehicle(client)
    if not vehicle or not isElement(vehicle) then
        -- Create new vehicle if current one is gone
        local model = getCurrentVehicle and getCurrentVehicle() or 415
        vehicle = createVehicle(model, x, y, z + 1, rx, ry, rz)
    end

    -- Resurrect player if they were dead
    if isPedDead(client) then
        spawnPlayer(client, x, y, z + 1, rz, getElementModel(client), getElementInterior(client), getElementDimension(client))
    end
    
    if vehicle and isElement(vehicle) then
        warpPedIntoVehicle(client, vehicle)
        setElementPosition(vehicle, x, y, z + 1)
        setElementRotation(vehicle, rx, ry, rz)
        setElementVelocity(vehicle, 0, 0, 0)
        setElementAngularVelocity(vehicle, 0, 0, 0)
        setElementFrozen(vehicle, true)
        fixVehicle(vehicle)
        setVehicleDamageProof(vehicle, true)
    end
    
    storedVelocity[client] = {vx, vy, vz}
    storedAngularVelocity[client] = {avx, avy, avz}
    
    toggleAllControls(client, false, true, false)
    
    -- Optional: Ghost mode to prevent getting stuck
    if type(makePlayerGhost) == "function" then
        makePlayerGhost(client, 2, true, false)
    end
end)

addEvent("onRespawnOnDamageRelease", true)
addEventHandler("onRespawnOnDamageRelease", resourceRoot, function()
    local vehicle = getPedOccupiedVehicle(client)
    if vehicle then
        setElementFrozen(vehicle, false)
        setVehicleDamageProof(vehicle, false)
        
        local vel = storedVelocity[client]
        if vel then
            setElementVelocity(vehicle, vel[1], vel[2], vel[3])
            storedVelocity[client] = nil
        end

        local avel = storedAngularVelocity[client]
        if avel then
            setElementAngularVelocity(vehicle, avel[1], avel[2], avel[3])
            storedAngularVelocity[client] = nil
        end
    end
    
    toggleAllControls(client, true, true, true)
    isRewinding[client] = false
    setElementData(client, "isRewinding", false)
end)

addEventHandler("onPlayerJoin", root, function()
    setElementData(source, "isRewinding", false)
    isRewinding[source] = false
end)

addEventHandler("onPlayerQuit", root, function()
    isRewinding[source] = nil
end)
