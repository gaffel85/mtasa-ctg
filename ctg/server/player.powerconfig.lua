local configs = {}
local bindableKeys = {"C", "Z"}

function getDefaultConfig()
    return {
        active = {
            { key = "nitro", bindKey = "lctrl" },
            { key = "teleport", bindKey = "X" },
            --{ key = "busses", bindKey = "C" },
            --{ key = "waterLevel", bindKey = "R" },
            --{ key = "canon", bindKey = "B" },
            --{ key = "plane", bindKey = "P" },
            --{ key = "cinematic", bindKey = "N" },
        },
        wanted = {},
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
    openConfigPanel(player, 1)
end

function bindConfigPowerKeys(player)
    bindKey ( player, "F3", "up", onOpenConfigPanelPressed, player )
end

function unbindConfigPowerKeys(player)
    unbindKey ( player, "F3" )
end

function onJoinForPowerKeys ( )
    bindConfigPowerKeys(source)
end
addEventHandler("onPlayerJoin", getRootElement(), onJoinForPowerKeys)

  --unbind on quit
function onQuitForPowerKeys ( )
    unbindConfigPowerKeys(source)
end
addEventHandler("onPlayerQuit", getRootElement(), onQuitForPowerKeys)

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), function()
    for k, player in ipairs(getElementsByType("player")) do
        bindConfigPowerKeys(player)
    end
end)