-- ctg/shared/temp_powers_config.lua
-- Shared repository for temporary, consumable power-ups.

TemporaryPowerups = {}

-- Function to register a temporary power-up
function registerTemporaryPower(id, config)
    if not id or not config then
        outputDebugString("Attempted to register temporary power without ID or config")
        return
    end
    config.id = id
    TemporaryPowerups[id] = config
    -- outputDebugString("Registered temporary power: " .. id)
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
        metadata[id] = {
            id = id,
            name = config.name,
            description = config.desc,
            iconPath = config.iconPath,
            duration = config.duration -- Include duration in metadata
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
