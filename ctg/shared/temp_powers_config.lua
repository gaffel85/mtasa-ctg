-- ctg/shared/temp_powers_config.lua
-- Defines configuration for temporary, consumable power-ups.

local TemporaryPowerups = {
    -- Example: Turn all other players into buses
    bus_transform = {
        id = "bus_transform",
        name = "Bus Transform",
        description = "Turn other players' vehicles into buses",
        iconPath = "img/bus_icon.png", -- Placeholder, replace with actual path if available
        serverEffectFunctionName = "transformPlayersIntoBuses", -- Placeholder, replace with actual server function
    },

    -- Example: Change camera angle for other players
    camera_chaos = {
        id = "camera_chaos",
        name = "Camera Chaos",
        description = "Change other players' camera angles randomly",
        iconPath = "img/camera_icon.png", -- Placeholder, replace with actual path if available
        serverEffectFunctionName = "applyCameraChaosToPlayers", -- Placeholder, replace with actual server function
    },

    -- Add more temporary power-ups here as needed
    -- e.g., speed_boost, shield, etc.
}

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

-- Export the table and helper functions for server/client use
return TemporaryPowerups
