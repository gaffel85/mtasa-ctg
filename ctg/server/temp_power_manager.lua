-- ctg/server/temp_power_manager.lua
-- Server-side module for managing temporary, consumable power-ups for players.

local playerPowerupQueues = {} -- Stores power-up queues for each player (key = player element, value = {powerupId1, powerupId2})
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
end

-- Initializes a player's power-up queue when they join
addEventHandler("onPlayerJoin", root, function()
    playerPowerupQueues[source] = {}
    -- Note: Sync will happen in onPlayerResourceStart when client is ready
end)

-- Cleans up a player's power-up queue when they quit
addEventHandler("onPlayerQuit", root, function()
    playerPowerupQueues[source] = nil
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

-- Function to find the player with the least points and give them a power-up
function givePowerToPlayerWithLeastPoints()
    local players = getElementsByType("player")
    if #players == 0 then return end

    local targetPlayer = nil
    local minScore = math.huge

    for _, player in ipairs(players) do
        -- Skip players with full queue to find someone else who might need it? 
        -- Or just pick the absolute lowest even if full? Usually Mario Kart style is to help the ones behind.
        local score = getPlayerScore(player) or 0
        if score < minScore then
            minScore = score
            targetPlayer = player
        end
    end

    if targetPlayer then
        local success, reason = giveRandomTemporaryPowerup(targetPlayer)
        if success then
            outputChatBox("Giving extra power-up to " .. getPlayerName(targetPlayer) .. " (Lowest points: " .. minScore .. ")", root, 0, 255, 0)
        else
            -- If the lowest player has a full queue, try to find the next one? 
            -- For now, let's just log it.
            outputDebugString("Could not give power to " .. getPlayerName(targetPlayer) .. ": " .. tostring(reason))
        end
    end
end

-- Command handler for admin/trigger
addCommandHandler("givepower", function(player)
    -- TODO: Add admin check here if needed
    outputServerLog("Power-giving command triggered by " .. (isElement(player) and getPlayerName(player) or "System"))
    givePowerToPlayerWithLeastPoints()
end)

-- Register server-side bind for P key
if registerBindFunctions then
    registerBindFunctions(function(player)
        bindKey(player, "p", "down", "givepower")
    end, function(player)
        unbindKey(player, "p", "down", "givepower")
    end)
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

    if powerupConfig.onActivated and type(powerupConfig.onActivated) == "function" then
        local vehicle = getPedOccupiedVehicle(targetPlayer)
        if vehicle then
            powerupConfig.onActivated(targetPlayer, vehicle, { name = powerupConfig.name or "Temporary Power"})
            outputDebugString("Player " .. getPlayerName(targetPlayer) .. " used temporary power-up: " .. powerupIdToUse)
        end
    elseif powerupConfig.serverEffectFunctionName and _G[powerupConfig.serverEffectFunctionName] then
        _G[powerupConfig.serverEffectFunctionName](targetPlayer)
        outputDebugString("Player " .. getPlayerName(targetPlayer) .. " used temporary power-up: " .. powerupIdToUse)
    else
        outputDebugString("Temporary power-up " .. powerupIdToUse .. " has no valid effect function.")
    end

    -- Broadcast activation to all clients for progress bars/notifications and global locking
    local durationValue = powerupConfig.duration
    if type(durationValue) == "function" then
        durationValue = durationValue()
    end

    if durationValue and durationValue > 0 then
        isGlobalPowerActive = true
        
        local effectId = getPlayerName(targetPlayer) .. "_" .. powerupIdToUse .. "_" .. getTickCount()
        activeEffectsServer[effectId] = {
            playerName = getPlayerName(targetPlayer),
            powerupId = powerupIdToUse,
            name = powerupConfig.name,
            duration = durationValue * 1000,
            endTime = getTickCount() + (durationValue * 1000)
        }

        if isTimer(globalPowerTimer) then killTimer(globalPowerTimer) end
        globalPowerTimer = setTimer(function(id, player, config)
            isGlobalPowerActive = false
            activeEffectsServer[id] = nil
            if config.onDeactivated then
                -- Call onDeactivated even if player is nil to allow global cleanup
                local vehicle = isElement(player) and getPedOccupiedVehicle(player) or nil
                config.onDeactivated(player, vehicle, { name = config.name })
            end
        end, durationValue * 1000, 1, effectId, targetPlayer, powerupConfig)
        
        triggerClientEvent(root, "onTempPowerupActivatedClient", root, getPlayerName(targetPlayer), powerupIdToUse, powerupConfig.name, durationValue)
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

-- Public function: Resets all temporary power-up states (called on round restart)
function resetTemporaryPowerState()
    if isTimer(globalPowerTimer) then
        killTimer(globalPowerTimer)
        globalPowerTimer = nil
    end
    
    -- Deactivate any active effects properly
    for id, effect in pairs(activeEffectsServer) do
        local player = getPlayerFromName(effect.playerName)
        local powerupConfig = getTemporaryPowerupConfig(effect.powerupId)
        if powerupConfig and powerupConfig.onDeactivated then
            -- Call even if player is nil to allow global cleanup
            local vehicle = isElement(player) and getPedOccupiedVehicle(player) or nil
            powerupConfig.onDeactivated(player, vehicle, { name = powerupConfig.name })
        end
    end

    isGlobalPowerActive = false
    activeEffectsServer = {}
    
    -- Notify all clients to clear their active effects UI
    triggerClientEvent(root, "onTempPowerupResetClient", root)
    outputDebugString("Temporary power-up state reset.")
end

-- Export functions globally
_G["giveRandomTemporaryPowerup"] = giveRandomTemporaryPowerup
_G["useTemporaryPowerup"] = useTemporaryPowerup
_G["getPlayerPowerupQueue"] = function(player) return playerPowerupQueues[player] end
_G["givePowerToPlayerWithLeastPoints"] = givePowerToPlayerWithLeastPoints
_G["resetTemporaryPowerState"] = resetTemporaryPowerState
