local superCatchupPlayers = {}
local storedVelocity = {}

addEvent("onSuperCatchupToggle", true)
addEventHandler("onSuperCatchupToggle", resourceRoot, function(targetPlayer, status)
    if getPlayerName(client) ~= "gaffel" then return end
    
    if isElement(targetPlayer) then
        superCatchupPlayers[targetPlayer] = status
        setElementData(targetPlayer, "hasSuperCatchup", status)
        outputChatBox("Super Catch-Up " .. (status and "granted" or "revoked") .. " for " .. getPlayerName(targetPlayer), client)
        outputChatBox("Admin " .. getPlayerName(client) .. " has " .. (status and "granted you" or "revoked your") .. " Super Catch-Up power.", targetPlayer)
    end
end)

addEvent("onSuperCatchupTeleport", true)
addEventHandler("onSuperCatchupTeleport", resourceRoot, function(x, y, z, rx, ry, rz, vx, vy, vz)
    --outputServerLog("[SCU-TRACE] onSuperCatchupTeleport called for " .. getPlayerName(client) .. " to pos: " .. x .. ", " .. y .. ", " .. z .. " rot: " .. rx .. ", " .. ry .. ", " .. rz .. " vel: " .. vx .. ", " .. vy .. ", " .. vz)
    local vehicle = getPedOccupiedVehicle(client)
    if vehicle then
        setElementPosition(vehicle, x, y, z + 1)
        setElementRotation(vehicle, rx, ry, rz)
        setElementVelocity(vehicle, 0, 0, 0)
        setElementFrozen(vehicle, true)
        storedVelocity[client] = {vx, vy, vz}
        
        -- Freeze matching collision repair logic
        toggleAllControls(client, false, true, false)
        setVehicleDamageProof(vehicle, true)
        
        -- Ghost mode (1s initial, but safeCheck=true will keep it until clear)
        if type(makePlayerGhost) == "function" then
            makePlayerGhost(client, 1, true, false)
        end
    end
end)

addEvent("onSuperCatchupRelease", true)
addEventHandler("onSuperCatchupRelease", resourceRoot, function()
    local vehicle = getPedOccupiedVehicle(client)
    if vehicle then
        setElementFrozen(vehicle, false)
        toggleAllControls(client, true, true, true)
        setVehicleDamageProof(vehicle, false)
        
        -- Use velocity stored at T=2s (when teleport/spawn happened)
        local vel = storedVelocity[client]
        if vel then
            setElementVelocity(vehicle, vel[1], vel[2], vel[3])
            storedVelocity[client] = nil
        end
    end
end)

function hasSuperCatchup(player)
    return getElementData(player, "hasSuperCatchup") or false
end

-- Sync on join
addEventHandler("onPlayerJoin", getRootElement(), function()
    setElementData(source, "hasSuperCatchup", false)
end)
