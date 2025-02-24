local configs = {}

function getDefaultConfig()
    return {
        active = {
            { key = "nitro", bindKey = "lctrl" },
            { key = "teleport", bindKey = "X" },
            { key = "superCar", bindKey = "C" },
            { key = "waterLevel", bindKey = "Z" }
        },
        owned = {
            "nitro",
            "teleport",
            "superCar",
            "waterLevel"
        },
    }
end

function getPlayerPowerConfig(player)
	local playerName = getPlayerName(player)
	local powerupConfig = configs[playerName]
	if (not powerupConfig) then
		powerupConfig = getDefaultConfig()
		configs[playerName] = powerupConfig
	end
	return powerupConfig
end