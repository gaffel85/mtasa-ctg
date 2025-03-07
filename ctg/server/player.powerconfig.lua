local configs = {}
local bindableKeys = {"X", "C"}

function getDefaultConfig()
    return {
        bindableKeys,
        active = {
            { key = "nitro", bindKey = "lctrl" },
            { key = "teleport", bindKey = "Z" },
            --{ key = "busses", bindKey = "C" },
            --{ key = "waterLevel", bindKey = "R" },
            --{ key = "canon", bindKey = "B" },
            --{ key = "plane", bindKey = "P" },
            --{ key = "cinematic", bindKey = "N" },
        },
        wanted = {},
        completedRank = 0,
        usedRank = 1,
        owned = {
            "nitro",
            "teleport",
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

function setPlayerPowerConfig(player, config)
    local oldConfig = getPlayerPowerConfig(player)
    local newPowers = {}
    for i, powerUp in ipairs(config.active) do
        local wasActiveInOldConfig = false
        for j, oldPowerUp in ipairs(oldConfig.active) do
            if powerUp.key == oldPowerUp.key then
                wasActiveInOldConfig = true
                break
            end
        end
        if not wasActiveInOldConfig then
            table.insert(newPowers, powerUp.key)
        end
    end
    configs[getPlayerName(player)] = config
    for i, powerUpKey in ipairs(newPowers) do
        local powerUp = findPowerUpWithKey(powerUpKey)
        resetPowerState(player, powerUp)
        config.usedRank = powerUp.rank
    end
end

addEvent("powerSelectedEvent")
addEventHandler("powerSelectedEvent", getResourceRootElement(getThisResource()), function(nextVehicle)
    if nextVehicle == currentVehicle then
        return
    end

    currentVehicle = nextVehicle
    setVehicleForAll()
end)

function powerSelected(player, powerUp, index)
    outputServerLog("powerSelected "..inspect(#powerUp).." "..inspect(index))
    local powerUpConfig = getPlayerPowerConfig(player)
    table.insert(powerUpConfig.wanted, { key = powerUp.key, bindKey = bindableKeys[index] })
    openConfigPanel(player, index + 1)
end

function openConfigPanel(player, index)
    outputServerLog("openConfigPanel "..inspect(#bindableKeys).." "..inspect(index))
    if index > #bindableKeys then
        return
    end

    local nextKey = bindableKeys[index]

    local baseSettings = {
        --start settings (dictionary part)
        title="Bind to "..nextKey,
        percentage=75,
        timeout=30,
        allowchange=false,
        maxnominations=1,
        visibleTo=player,
        --start options (array part)
    }

    for i, powerUpKey in ipairs(getPlayerPowerConfig(player).owned) do
        local powerUp = findPowerUpWithKey(powerUpKey)
        baseSettings[i] = {powerUp.name, "powerSelectedEvent", nil, player, powerUp, index}
    end

    exports.votemanager:startPoll(baseSettings)
end

function onOpenConfigPanelPressed(player)
    local data = getPlayerPowerConfig(player)
	triggerClientEvent(player, "onOpenPowerConfigWindowClient", player, data)
end

addEvent("loadPowerupsConfigServer", true)
addEventHandler("loadPowerupsConfigServer", root, function()
	local data = getPlayerPowerConfig(client)
	triggerClientEvent(client, "onPowerupsConfigLoadedClient", this, data)
end)

addEvent("setConfigFromClient", true)
addEventHandler("setConfigFromClient", root, function(config)
	setPlayerPowerConfig(client, config)
end)