-- ctg/server/temp_power_manager.lua
-- Server-side module for managing temporary, consumable power-ups for players.

local playerPowerupQueues = {} -- Stores power-up queues for each player (key = player element, value = {powerupId1, powerupId2})
local MAX_QUEUE_SIZE = 2
local WARNING_DURATION = 3 -- Seconds of warning before activation

local isGlobalPowerActive = false
local globalPowerTimer = nil
local activeEffectsServer = {} -- { [id] = {playerName, powerupId, name, duration, endTime} }

-- Individual power quotas (weights for randomness)
local powerQuotas = {} -- [powerupId] = integer weight

-- Function to get a random power-up ID from the config based on quotas
local function getRandomPowerupId()
    local allPowerupIds = getAllTemporaryPowerupIds()
    if #allPowerupIds == 0 then
        return nil
    end

    local totalQuota = 0
    local ticketBuckets = {} -- { {id, min, max} }
    
    for _, id in ipairs(allPowerupIds) do
        local quota = math.floor(tonumber(powerQuotas[id]) or 1)
        if quota > 0 then
            local min = totalQuota + 1
            totalQuota = totalQuota + quota
            local max = totalQuota
            table.insert(ticketBuckets, {id = id, min = min, max = max})
        end
    end

    if totalQuota <= 0 then
        -- Fallback if all quotas are 0
        local randomIndex = math.random(1, #allPowerupIds)
        return allPowerupIds[randomIndex]
    end

    local randomTicket = math.random(1, totalQuota)
    for _, bucket in ipairs(ticketBuckets) do
        if randomTicket >= bucket.min and randomTicket <= bucket.max then
            return bucket.id
        end
    end

    return allPowerupIds[1]
end

-- Helper to sync power-up metadata and current queue to a player
local function syncPlayerPowerups(player)
    if not isElement(player) or getElementType(player) ~= "player" then return end
    
    -- Send all registered temporary powerup metadata to client
    triggerClientEvent(player, "onSyncTemporaryPowerupsMetadata", player, getTemporaryPowerupsMetadata())
    
    -- Send current individual quotas
    triggerClientEvent(player, "onSyncTempPowerQuota", player, powerQuotas)

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
end)

-- Cleans up a player's power-up queue when they quit
addEventHandler("onPlayerQuit", root, function()
    playerPowerupQueues[source] = nil
end)

-- Sync when the client resource is started (handles resource restarts and joins)
addEventHandler("onPlayerResourceStart", root, function(startedResource)
    if startedResource == resource then
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
    
    -- Final sync after 1 second to ensure all sub-scripts (powerups) have registered
    setTimer(function()
        for _, player in ipairs(getElementsByType("player")) do
            syncPlayerPowerups(player)
        end
        outputDebugString("[TEMP POWER] Final resource-start sync completed")
    end, 1000, 1)
end)

-- Debug command to check server state
addCommandHandler("checktempserv", function(player)
    local allIds = getAllTemporaryPowerupIds()
    local msg = "[SERVER] Temporary Powerups registered: " .. #allIds
    if isElement(player) then
        outputChatBox(msg, player)
    else
        outputServerLog(msg)
    end
    for _, id in ipairs(allIds) do
        local config = getTemporaryPowerupConfig(id)
        local detail = " - " .. tostring(id) .. " (" .. tostring(config.name) .. ")"
        if isElement(player) then outputChatBox(detail, player) else outputServerLog(detail) end
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
            outputDebugString("Could not give power to " .. getPlayerName(targetPlayer) .. ": " .. tostring(reason))
        end
    end
end

-- Command handler for admin/trigger
addCommandHandler("givepower", function(player)
    if isElement(player) and getPlayerName(player) ~= "gaffel" then
        return
    end
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

    -- Lock the global power state and start the warning phase
    isGlobalPowerActive = true
    outputServerLog("[TEMP POWER] Starting 3s warning for " .. powerupIdToUse .. " by " .. getPlayerName(targetPlayer))

    -- Notify all players about the upcoming power
    triggerClientEvent(root, "onTempPowerupWarningClient", targetPlayer, powerupIdToUse, powerupConfig.name, WARNING_DURATION)

    -- Set timer for the actual activation
    globalPowerTimer = setTimer(function(player, pId)
        if not isElement(player) then
            isGlobalPowerActive = false
            return
        end

        local config = getTemporaryPowerupConfig(pId)
        if not config then
            isGlobalPowerActive = false
            outputDebugString("Temporary power-up " .. pId .. " config lost during activation delay.")
            return
        end

        outputServerLog("[TEMP POWER] Activation delay finished for " .. pId .. " by " .. getPlayerName(player))

        -- Execute activation
        if config.onActivated and type(config.onActivated) == "function" then
            local vehicle = getPedOccupiedVehicle(player)
            if vehicle then
                config.onActivated(player, vehicle, { name = config.name or "Temporary Power"})
                outputDebugString("Player " .. getPlayerName(player) .. " used temporary power-up: " .. pId)
            end
        elseif config.serverEffectFunctionName and _G[config.serverEffectFunctionName] then
            _G[config.serverEffectFunctionName](player)
            outputDebugString("Player " .. getPlayerName(player) .. " used temporary power-up: " .. pId)
        else
            outputDebugString("Temporary power-up " .. pId .. " has no valid effect function.")
        end

        -- Broadcast activation to all clients for progress bars/notifications and global locking
        local durationValue = config.duration
        if type(durationValue) == "function" then
            durationValue = durationValue()
        end

        if durationValue and durationValue > 0 then
            local effectId = getPlayerName(player) .. "_" .. pId .. "_" .. getTickCount()
            outputServerLog("[TEMP POWER] Activating " .. pId .. " for " .. getPlayerName(player) .. " (Duration: " .. durationValue .. "s)")
            
            activeEffectsServer[effectId] = {
                playerName = getPlayerName(player),
                powerupId = pId,
                name = config.name,
                duration = durationValue * 1000,
                endTime = getTickCount() + (durationValue * 1000)
            }

            globalPowerTimer = setTimer(function(id, p, pid)
                outputServerLog("[TEMP POWER] Timer expired for " .. pid .. " (Player: " .. (isElement(p) and getPlayerName(p) or "Left") .. ")")
                
                local cfg = getTemporaryPowerupConfig(pid)
                isGlobalPowerActive = false
                activeEffectsServer[id] = nil
                if cfg and cfg.onDeactivated then
                    outputServerLog("[TEMP POWER] Calling onDeactivated for " .. pid)
                    local v = isElement(p) and getPedOccupiedVehicle(p) or nil
                    cfg.onDeactivated(p, v, { name = cfg.name })
                end
            end, durationValue * 1000, 1, effectId, player, pId)
            
            triggerClientEvent(root, "onTempPowerupActivatedClient", root, getPlayerName(player), pId, config.name, durationValue)
        else
            isGlobalPowerActive = false
        end
    end, WARNING_DURATION * 1000, 1, targetPlayer, powerupIdToUse)

    -- Notify client about the updated queue
    triggerClientEvent(targetPlayer, "onTempPowerupQueueUpdateClient", targetPlayer, playerQueue)
    return true
end

-- Listen for client request to use power-up
addEvent("onUseTemporaryPowerupServer", true)
addEventHandler("onUseTemporaryPowerupServer", root, function()
    useTemporaryPowerup(client)
end)

-- Public function: Resets all temporary power-up states
function resetTemporaryPowerState()
    if isTimer(globalPowerTimer) then
        killTimer(globalPowerTimer)
        globalPowerTimer = nil
    end
    
    for id, effect in pairs(activeEffectsServer) do
        local player = getPlayerFromName(effect.playerName)
        local powerupConfig = getTemporaryPowerupConfig(effect.powerupId)
        if powerupConfig and powerupConfig.onDeactivated then
            local vehicle = isElement(player) and getPedOccupiedVehicle(player) or nil
            powerupConfig.onDeactivated(player, vehicle, { name = powerupConfig.name })
        end
    end

    isGlobalPowerActive = false
    activeEffectsServer = {}
    
    triggerClientEvent(root, "onTempPowerupResetClient", root)
    outputDebugString("Temporary power-up state reset.")
end

-- Event to update quotas from admin
addEvent("onSetTempPowerQuota", true)
addEventHandler("onSetTempPowerQuota", root, function(newPowerQuotas)
    if newPowerQuotas ~= nil and type(newPowerQuotas) == "table" then
        for id, quota in pairs(newPowerQuotas) do
            powerQuotas[id] = math.floor(tonumber(quota) or 1)
        end
        outputServerLog("Admin " .. getPlayerName(client) .. " updated power quotas")
        -- Sync to everyone on change
        triggerClientEvent(root, "onSyncTempPowerQuota", root, powerQuotas)
    else
        -- Sync only to requester on request (nil payload)
        triggerClientEvent(client, "onSyncTempPowerQuota", client, powerQuotas)
    end
end)

-- Export functions globally
_G["giveRandomTemporaryPowerup"] = giveRandomTemporaryPowerup
_G["useTemporaryPowerup"] = useTemporaryPowerup
_G["getPlayerPowerupQueue"] = function(player) return playerPowerupQueues[player] end
_G["givePowerToPlayerWithLeastPoints"] = givePowerToPlayerWithLeastPoints
_G["resetTemporaryPowerState"] = resetTemporaryPowerState
