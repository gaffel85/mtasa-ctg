-- ctg/server/temp_power_manager.lua
-- Server-side module for managing temporary, consumable power-ups for players.

local playerPowerupQueues = {} -- Stores power-up queues for each player (key = player element, value = {powerupId1, powerupId2})
local playerTestTimers = {} -- Stores test timers for each player
local MAX_QUEUE_SIZE = 2

local isGlobalPowerActive = false
local globalPowerTimer = nil
local activeEffectsServer = {} -- { [id] = {playerName, powerupId, name, duration, endTime} }

-- Function to get a random power-up ID from the config
local function getRandomPowerupId()
    local allPowerupIds = getAllTemporaryPowerupIds()
    if #allPowerupIds == 0 then
        return nil
    end
    local randomIndex = math.random(1, #allPowerupIds)
    return allPowerupIds[randomIndex]
end

-- Helper to sync power-up metadata and current queue to a player
local function syncPlayerPowerups(player)
    if not isElement(player) or getElementType(player) ~= "player" then return end
    
    -- Send all registered temporary powerup metadata to client
    triggerClientEvent(player, "onSyncTemporaryPowerupsMetadata", player, getTemporaryPowerupsMetadata())
    
    -- Send any currently active effects to the joining player
    local currentTime = getTickCount()
    for id, effect in pairs(activeEffectsServer) do
        local timeLeft = effect.endTime - currentTime
        if timeLeft > 0 then
            triggerClientEvent(player, "onTempPowerupActivatedClient", player, effect.playerName, effect.powerupId, effect.name, timeLeft / 1000)
        else
            activeEffectsServer[id] = nil
        end
    end

    -- Send the current queue to the client
    local playerQueue = playerPowerupQueues[player] or {}
    triggerClientEvent(player, "onTempPowerupQueueUpdateClient", player, playerQueue)
    -- giveRandomTemporaryPowerup(player)

    -- DEBUG/TEST: Automatically give a power-up every 10 seconds
    if isTimer(playerTestTimers[player]) then killTimer(playerTestTimers[player]) end
    playerTestTimers[player] = setTimer(function(p)
        if isElement(p) then
            giveRandomTemporaryPowerup(p)
        end
    end, 10000, 0, player)
end

-- Initializes a player's power-up queue when they join
addEventHandler("onPlayerJoin", root, function()
    playerPowerupQueues[source] = {}
    -- Note: Sync will happen in onPlayerResourceStart when client is ready
end)

-- Cleans up a player's power-up queue when they quit
addEventHandler("onPlayerQuit", root, function()
    playerPowerupQueues[source] = nil
    if isTimer(playerTestTimers[source]) then
        killTimer(playerTestTimers[source])
    end
    playerTestTimers[source] = nil
end)

-- Sync when the client resource is started (handles resource restarts and joins)
addEventHandler("onPlayerResourceStart", root, function(startedResource)
    if startedResource == resource then
        -- source is the player who just started the resource
        if not playerPowerupQueues[source] then
            playerPowerupQueues[source] = {}
        end
        syncPlayerPowerups(source)
    end
end)

-- Handle existing players when the resource starts
addEventHandler("onResourceStart", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do
        if not playerPowerupQueues[player] then
            playerPowerupQueues[player] = {}
        end
        -- We don't sync here; onPlayerResourceStart will trigger for all existing players
        -- once their client-side scripts are ready.
    end
end)

-- Public function: Gives a random temporary power-up to a player
function giveRandomTemporaryPowerup(targetPlayer)
    if not isElement(targetPlayer) or getElementType(targetPlayer) ~= "player" then
        return false, "Invalid player"
    end

    local playerQueue = playerPowerupQueues[targetPlayer]
    if not playerQueue then
        playerPowerupQueues[targetPlayer] = {}
        playerQueue = playerPowerupQueues[targetPlayer]
    end

    if #playerQueue >= MAX_QUEUE_SIZE then
        outputDebugString("Player " .. getPlayerName(targetPlayer) .. " has a full temporary power-up queue. Ignoring new power-up.")
        return false, "Queue full"
    end

    local powerupId = getRandomPowerupId()
    if not powerupId then
        outputDebugString("No temporary power-ups defined to give.")
        return false, "No power-ups defined"
    end

    table.insert(playerQueue, powerupId)
    outputDebugString("Player " .. getPlayerName(targetPlayer) .. " received temporary power-up: " .. powerupId .. ". Queue size: " .. #playerQueue)

    -- Notify client about the updated queue
    triggerClientEvent(targetPlayer, "onTempPowerupQueueUpdateClient", targetPlayer, playerQueue)
    return true
end

-- Public function: Uses the player's current (first in queue) temporary power-up
function useTemporaryPowerup(targetPlayer)
    if not isElement(targetPlayer) or getElementType(targetPlayer) ~= "player" then
        return false, "Invalid player"
    end

    if isGlobalPowerActive then
        outputDebugString("Player " .. getPlayerName(targetPlayer) .. " tried to use a temporary power-up but another power is already active.")
        return false, "Another power active"
    end

    local playerQueue = playerPowerupQueues[targetPlayer]
    if not playerQueue or #playerQueue == 0 then
        outputDebugString("Player " .. getPlayerName(targetPlayer) .. " tried to use a temporary power-up but their queue is empty.")
        return false, "Queue empty"
    end

    local powerupIdToUse = table.remove(playerQueue, 1) -- Remove the first power-up
    local powerupConfig = getTemporaryPowerupConfig(powerupIdToUse)

    if not powerupConfig then
        outputDebugString("Tried to use unknown temporary power-up ID: " .. powerupIdToUse)
        triggerClientEvent(targetPlayer, "onTempPowerupQueueUpdateClient", targetPlayer, playerQueue)
        return false, "Unknown power-up ID"
    end

    if powerupConfig.onActivate and type(powerupConfig.onActivate) == "function" then
        powerupConfig.onActivate(targetPlayer)
        outputDebugString("Player " .. getPlayerName(targetPlayer) .. " used temporary power-up: " .. powerupIdToUse)
    elseif powerupConfig.serverEffectFunctionName and _G[powerupConfig.serverEffectFunctionName] then
        _G[powerupConfig.serverEffectFunctionName](targetPlayer)
        outputDebugString("Player " .. getPlayerName(targetPlayer) .. " used temporary power-up: " .. powerupIdToUse)
    else
        outputDebugString("Temporary power-up " .. powerupIdToUse .. " has no valid effect function.")
    end

    -- Broadcast activation to all clients for progress bars/notifications and global locking
    if powerupConfig.duration and powerupConfig.duration > 0 then
        isGlobalPowerActive = true
        
        local effectId = getPlayerName(targetPlayer) .. "_" .. powerupIdToUse .. "_" .. getTickCount()
        activeEffectsServer[effectId] = {
            playerName = getPlayerName(targetPlayer),
            powerupId = powerupIdToUse,
            name = powerupConfig.name,
            duration = powerupConfig.duration * 1000,
            endTime = getTickCount() + (powerupConfig.duration * 1000)
        }

        if isTimer(globalPowerTimer) then killTimer(globalPowerTimer) end
        globalPowerTimer = setTimer(function(id)
            isGlobalPowerActive = false
            activeEffectsServer[id] = nil
        end, powerupConfig.duration * 1000, 1, effectId)
        
        triggerClientEvent(root, "onTempPowerupActivatedClient", root, getPlayerName(targetPlayer), powerupIdToUse, powerupConfig.name, powerupConfig.duration)
    end

    -- Notify client about the updated queue
    triggerClientEvent(targetPlayer, "onTempPowerupQueueUpdateClient", targetPlayer, playerQueue)
    return true
end

-- Listen for client request to use power-up
addEvent("onUseTemporaryPowerupServer", true)
addEventHandler("onUseTemporaryPowerupServer", root, function()
    useTemporaryPowerup(client)
end)

-- Export functions globally
_G["giveRandomTemporaryPowerup"] = giveRandomTemporaryPowerup
_G["useTemporaryPowerup"] = useTemporaryPowerup
_G["getPlayerPowerupQueue"] = function(player) return playerPowerupQueues[player] end
