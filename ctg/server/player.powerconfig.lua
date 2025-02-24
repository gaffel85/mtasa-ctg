local configs = {}

function getDefaultConfig()
    return {
        active = {
            { key = "nitro", bindKey = "lctrl" },
            { key = "teleport", bindKey = "X" },
            { key = "busses", bindKey = "C" },
            { key = "waterLevel", bindKey = "R" },
            { key = "canon", bindKey = "B" },
            { key = "plane", bindKey = "P" },
            { key = "cinematic", bindKey = "N" },
        },
        owned = {
            "nitro",
            "teleport",
            "busses",
            "waterLevel",
            "canon",
            "plane",
            "cinematic",
            "superCar",
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