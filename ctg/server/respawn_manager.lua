local storedVelocity = {}
local storedAngularVelocity = {}

addEvent("onRespawnOnDamageTeleport", true)
addEventHandler("onRespawnOnDamageTeleport", resourceRoot, function(x, y, z, rx, ry, rz, vx, vy, vz, avx, avy, avz)
    local vehicle = getPedOccupiedVehicle(client)
    if vehicle then
        -- Drop gold if carrier
        if client == getGoldCarrier() then
            local px, py, pz = getElementPosition(client)
            clearGoldCarrier()
            spawnGoldAtTransform(px, py, pz)
            refreshAllBlips()
        end

        setElementPosition(vehicle, x, y, z + 1)
        setElementRotation(vehicle, rx, ry, rz)
        setElementVelocity(vehicle, 0, 0, 0)
        setElementAngularVelocity(vehicle, 0, 0, 0)
        setElementFrozen(vehicle, true)
        
        storedVelocity[client] = {vx, vy, vz}
        storedAngularVelocity[client] = {avx, avy, avz}
        
        toggleAllControls(client, false, true, false)
        setVehicleDamageProof(vehicle, true)
        fixVehicle(vehicle)

        -- Optional: Ghost mode to prevent getting stuck
        if type(makePlayerGhost) == "function" then
            makePlayerGhost(client, 2, true, false)
        end
    end
end)

addEvent("onRespawnOnDamageRelease", true)
addEventHandler("onRespawnOnDamageRelease", resourceRoot, function()
    local vehicle = getPedOccupiedVehicle(client)
    if vehicle then
        setElementFrozen(vehicle, false)
        toggleAllControls(client, true, true, true)
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
end)
