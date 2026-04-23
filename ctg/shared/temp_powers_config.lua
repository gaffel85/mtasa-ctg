-- ctg/shared/temp_powers_config.lua
-- Shared repository for temporary, consumable power-ups.
outputDebugString("[TEMP POWER] shared/temp_powers_config.lua loaded (Side: " .. (triggerServerEvent and "Client" or "Server") .. ")")

TemporaryPowerups = {}

-- Function to register a temporary power-up
function registerTemporaryPower(id, config)
    if not id or not config then
        outputDebugString("Attempted to register temporary power without ID or config")
        return
    end
    config.id = id
    TemporaryPowerups[id] = config
    outputDebugString("[TEMP POWER] Registered: " .. tostring(id) .. " (Side: " .. (triggerServerEvent and "Client" or "Server") .. ")")

    -- If registered on server, broadcast to all clients
    if not triggerServerEvent then
        local metadata = getTemporaryPowerupsMetadata()
        triggerClientEvent(root, "onSyncTemporaryPowerupsMetadata", root, metadata)
    end
end

-- Function to retrieve a power-up's config by ID
function getTemporaryPowerupConfig(id)
    return TemporaryPowerups[id]
end

-- Function to get a list of all power-up IDs
function getAllTemporaryPowerupIds()
    local ids = {}
    for id, _ in pairs(TemporaryPowerups) do
        table.insert(ids, id)
    end
    return ids
end

-- Function to get metadata for client-server synchronization
function getTemporaryPowerupsMetadata()
    local metadata = {}
    for id, config in pairs(TemporaryPowerups) do
        local durationVal = 0
        local success, result = pcall(function()
            if type(config.duration) == "function" then
                return config.duration()
            else
                return config.duration
            end
        end)
        if success then
            durationVal = result
        else
            outputDebugString("[TEMP POWER] Error calculating duration for " .. tostring(id) .. ": " .. tostring(result))
        end
        
        metadata[id] = {
            id = id,
            name = config.name,
            description = config.desc or config.description,
            iconPath = config.iconPath,
            duration = durationVal -- Include evaluated duration in metadata
        }
    end
    return metadata
end

-- Client-side event for receiving metadata from the server
if triggerServerEvent then -- Simple check for client-side
    addEvent("onSyncTemporaryPowerupsMetadata", true)
    addEventHandler("onSyncTemporaryPowerupsMetadata", root, function(metadata)
        for id, config in pairs(metadata) do
            TemporaryPowerups[id] = config
        end
        -- outputDebugString("Received temporary powerups metadata from server")
    end)
end
