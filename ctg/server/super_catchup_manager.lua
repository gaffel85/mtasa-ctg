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
    outputServerLog("[SCU-TRACE] onSuperCatchupTeleport called for " .. getPlayerName(client) .. " to pos: " .. x .. ", " .. y .. ", " .. z)
    local vehicle = getPedOccupiedVehicle(client)
    if vehicle then
        setElementPosition(vehicle, x, y, z + 1)
        setElementRotation(vehicle, rx, ry, rz)
        setElementVelocity(vehicle, 0, 0, 0)
        storedVelocity[client] = {vx, vy, vz}
        
        -- Freeze matching collision repair logic
        toggleAllControls(client, false, true, false)
        setVehicleDamageProof(vehicle, true)
        
        -- Ghost mode (1s initial, but safeCheck=true will keep it until clear)
        if type(makePlayerGhost) == "function" then
            outputServerLog("[SCU-TRACE] Applying ghost mode for " .. getPlayerName(client))
            makePlayerGhost(client, 1, true, false)
        else
            outputServerLog("[SCU-TRACE] WARNING: makePlayerGhost function not found!")
        end
    else
        outputServerLog("[SCU-TRACE] ERROR: No vehicle found for " .. getPlayerName(client))
    end
end)

addEvent("onSuperCatchupRelease", true)
addEventHandler("onSuperCatchupRelease", resourceRoot, function()
    outputServerLog("[SCU-TRACE] onSuperCatchupRelease called for " .. getPlayerName(client))
    local vehicle = getPedOccupiedVehicle(client)
    if vehicle then
        toggleAllControls(client, true, true, true)
        setVehicleDamageProof(vehicle, false)
        
        -- Use velocity stored at T=2s (when teleport/spawn happened)
        local vel = storedVelocity[client]
        if vel then
            outputServerLog("[SCU-TRACE] Applying T=2s leader velocity to " .. getPlayerName(client) .. ": " .. vel[1] .. ", " .. vel[2] .. ", " .. vel[3])
            setElementVelocity(vehicle, vel[1], vel[2], vel[3])
            storedVelocity[client] = nil
        else
            outputServerLog("[SCU-TRACE] WARNING: No stored T=2s velocity found for " .. getPlayerName(client))
        end
    else
        outputServerLog("[SCU-TRACE] ERROR: No vehicle found for release of " .. getPlayerName(client))
    end
end)

function hasSuperCatchup(player)
    return getElementData(player, "hasSuperCatchup") or false
end

-- Sync on join
addEventHandler("onPlayerJoin", getRootElement(), function()
    setElementData(source, "hasSuperCatchup", false)
end)
