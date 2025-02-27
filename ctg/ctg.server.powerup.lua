local nitroPowerUp = {
	key = "nitro",
	name = "Nitro",
	desc = "Nitro is a powerup that gives you a speed boost for a short period of time. It can be activated by pressing the left control key.",
	bindKey = "lctrl",
	cooldown = BOOST_COOLDOWN,
	duration = NITRO_DURATION,
	initCooldown = 5,
	allowedGoldCarrier = false,
	onEnable = function(player, vehicle)
		-- outputChatBox("Nitro enabled "..getPlayerName(player))
		addVehicleUpgrade(vehicle, 1009)
		return true
	end,
	onDisable = function(player, vehicle)
		-- outputChatBox("Nitro onDisabled"..getPlayerName(player))
		removeVehicleUpgrade(vehicle, 1009)
	end,
	onActivated = function(player, vehicle)
		-- outputChatBox("Nitro activated"..getPlayerName(player))
	end,
	onDeactivated = function(player, vehicle)
		-- outputChatBox("Nitro deactivated"..getPlayerName(player))
		removeVehicleUpgrade(vehicle, 1009)
	end	
}

local teleportPowerUp = {
	key = "teleport",
	name = "Catch up",
	desc = "Teleports you to a better location to catch up with the leader. Useful when you are about to give up. Can only be used when you are far enough from the leader.",
	bindKey = "x",
	cooldown = TELEPORT_COOLDOWN,
	duration = 0,
	initCooldown = 8,
	allowedGoldCarrier = false,
	onEnable = function(player, vehicle)
		-- outputChatBox("teleport enabled "..getPlayerName(player))
		return isFarEnoughFromLeader(player)
	end,
	onDisable = function(player, vehicle)
	end,
	onActivated = function(player, vehicle)
		-- askForTeleport(player)
		spawnCloseToLeader(player)
	end,
	onDeactivated = function(player, vehicle)
	end	
}

local powerUpStates = {}
local powerUps = {}

function addPowerUp(powerUp)
	table.insert(powerUps, powerUp)
	powerUpStates[powerUp.key] = {}
end

function setBoostCooldown(cooldown, state)
	local time = getRealTime()
	local boostCooldown = time.timestamp + cooldown
	state.cooldownEnd = boostCooldown
	local timeLeft = boostCooldownLeft(state)
end

function setPowerUpEndsTime(powerUp, state)
	local time = getRealTime()
	local endsTime = time.timestamp + powerUp.duration
	state.durationEnd = endsTime
end

function resetBoosterCountdown(powerUp)
	if (powerUp.activated) then
		powerUp.activated = false
		setBoostCooldown(powerUp)
	end
end

function boostCooldownLeft(powerUpState) 
	local currentTime = getRealTime()
	return powerUpState.cooldownEnd - currentTime.timestamp
end

function durationLeft(powerUpState) 
	local currentTime = getRealTime()
	return powerUpState.durationEnd - currentTime.timestamp
end

function getPlayerState(player, powerUp)
	local states = powerUpStates[powerUp.key]
	local playerName = getPlayerName(player)
	local powerUpState = states[playerName]
	if (not powerUpState) then
		powerUpState = {
			enabled = false,
			activated = false,
			durationEnd = nil,
			cooldownEnd = 0,
			charges = powerUp.charges,
			name = powerUp.name
		}
		setBoostCooldown(powerUp.initCooldown, powerUpState)
		states[playerName] = powerUpState
	end
	return powerUpState
end

function findPowerUpWithKey(key)
	for i, powerUp in ipairs(powerUps) do
		if (powerUp.key == key) then
			return powerUp
		end
	end
	return nil
end

function getPowerUps()
	return powerUps
end

function getPowerUpsData()
	local data = {}
	for i, powerUp in ipairs(powerUps) do
		table.insert(data, {
			key = powerUp.key,
			name = powerUp.name,
			desc = powerUp.desc,
			bindKey = powerUp.bindKey,
			cooldown = powerUp.cooldown,
			duration = powerUp.duration,
			charges = powerUp.charges,
			initCooldown = powerUp.initCooldown,
			allowedGoldCarrier = powerUp.allowedGoldCarrier
		})
	end
	return data
end

function usePowerUp(player, key, keyState, powerUp)
	--outputServerLog("usePowerUp "..getPlayerName(player).." "..powerUp.name.." "..key.." "..keyState)
	-- outputChatBox("usePowerUp "..getPlayerName(player).." "..powerUp.name.." "..key.." "..keyState)
	local state = getPlayerState(player, powerUp)
	state.activated = true
	setPowerUpEndsTime(powerUp, state)
	-- outputChatBox("state: "..tostring(state.activated))
	--outputServerLog("state: "..inspect(state))
	local vehicle = getPedOccupiedVehicle(player)
	if (vehicle) then
		local realPowerUp = findPowerUpWithKey(powerUp.key)
		--outputServerLog("realPowerUp: "..tostring(realPowerUp.name))
		if (realPowerUp) then
			--outputServerLog("activating: "..tostring(realPowerUp.name))
			realPowerUp.onActivated(player, vehicle, state)
		end
	else
		-- outputChatBox("vehicle is nil")
	end
	
	--unbindKey(player, key, keyState, usePowerUp, powerUp)
end

--addEvent("powerupSetCooldownClient", true)
--addEvent("powerupSetReadyClient", true)
--addEvent("powerupSetDisabledClient", true)
--addEvent("powerupSetDurationClient", true)

function tickPowerUps()
	for i, player in ipairs(getElementsByType("player")) do
		local powerConfig = getPlayerPowerConfig(player)
		for j, powerUpConfig in ipairs(powerConfig.active) do
			local powerUp = findPowerUpWithKey(powerUpConfig.key)
			if powerUp == nil then
				outputChatBox("powerUp is nil "..inspect(powerUpConfig.key))
			end
			local powerUpState = getPlayerState(player, powerUp)

			--outputConsole("loop state: "..inspect(powerUpState))
			--outputChatBox("timeLeft "..inspect(powerUpState.name)..inspect(powerUp.key))
			--outputChatBox("timeLeft "..timeLeft)

			if (player == getGoldCarrier() and not powerUp.allowedGoldCarrier) then
				-- outputChatBox("player is gold carrier")
				if (powerUpState.enabled) then
					--unbindKey(player, powerUpConfig.bindKey, "down", usePowerUp, powerUp)
					powerUp.onDisable(player, getPedOccupiedVehicle(player), powerUpState)
					powerUpState.enabled = false
				end
				if (powerUpState.activated) then
					powerUp.onDeactivated(player, getPedOccupiedVehicle(player), powerUpState)
					powerUpState.activated = false
					powerUpState.enabled = false
				end
			else
				if (powerUpState.activated == true) then
					-- outputChatBox("powerUpState.actived ==============")
					local timeLeft = durationLeft(powerUpState)
					-- outputChatBox("timeLeft "..timeLeft)
					if (timeLeft >= 0) then
						--outputChatBox("triggerClientEvent "..timeLeft.." "..powerUp.duration.." "..j.." "..powerUp.name.." "..powerUp.bindKey.." true")
						triggerClientEvent(player, "boosterDurationTick", player, timeLeft, powerUp.duration, j, powerUp.name, powerUpConfig.bindKey, true)
					end

					if (timeLeft <= 0) then
						--outputChatBox("timeLeft <= 0")
						local vehicle = getPedOccupiedVehicle (player)
						if (vehicle) then
							--outputChatBox("deactivate powerUp")
							powerUp.onDeactivated(player, vehicle, powerUpState)
							powerUpState.activated = false
							powerUpState.enabled = false
							setBoostCooldown(powerUp.cooldown, powerUpState)
							--outputChatBox("cooldown reset to "..powerUpState.cooldownEnd)
						end
					end
				elseif (powerUpState.enabled == false) then
					--outputChatBox("powerUpState.enabled == false")
					local timeLeft = boostCooldownLeft(powerUpState)
					--outputChatBox("timeLeft "..timeLeft)
					if (timeLeft >= 0) then
						--outputChatBox("triggerClientEvent "..timeLeft.." "..powerUp.cooldown.." "..j.." "..powerUp.name.." "..powerUp.bindKey.." true")
						triggerClientEvent(player, "boosterCooldownTick", player, timeLeft, powerUp.cooldown, j, powerUp.name, powerUpConfig.bindKey, true)
					end

					if (timeLeft <= 0) then
						-- outputChatBox("timeLeft <= 0 powerup: "..inspect(powerUp.name))
						local vehicle = getPedOccupiedVehicle (player)
						if (vehicle) then
							local wasEnabled = powerUp.onEnable(player, vehicle)
							--outputChatBox("wasEnabled "..tostring(wasEnabled))
							if (wasEnabled) then
								--outputChatBox("bindKey "..powerUp.bindKey)
								--bindKey(player, powerUpConfig.bindKey, "down", usePowerUp, powerUp)
								powerUpState.enabled = true
								powerUpState.activated = false
							end
						end
					end
				end
			end
		end
	end
end
setTimer(tickPowerUps, 1000, 0)

addEvent("loadPowerUpsServer", true)
addEventHandler("loadPowerUpsServer", root, function()
	local data = getPowerUpsData()
	--triggerClientEvent("onPowerupsLoadedClient", getRootElement(), data)
	triggerClientEvent(client, "onPowerupsLoadedClient", this, data)
	--triggerClientEvent(source, "onPowerupsLoadedClient", this, data)
end)

addPowerUp(nitroPowerUp)
addPowerUp(teleportPowerUp)

function powerButtonPressed(player, button)
	local powerConfig = getPlayerPowerConfig(player)
	local powerForBoundKey = nil
	for i, powerUpConfig in ipairs(powerConfig.active) do
		-- compare both with lower and upper case
		if (string.lower(powerUpConfig.bindKey) == string.lower(button)) then
			powerForBoundKey = powerUpConfig
			break
		end
	end

	local powerUpState = nil
	local powerUp = nil
	if (powerForBoundKey) then
		powerUp = findPowerUpWithKey(powerForBoundKey.key)
		if (powerUp) then
			powerUpState = getPlayerState(player, powerUp)
		end
	else 
		outputChatBox("No power bound for button: "..button)
	end

	if powerUpState then
	 	if powerUpState.enabled and not powerUpState.activated then
			usePowerUp(player, button, "up", powerUp)
		else
			outputChatBox("Power not ready yet: "..inspect(powerUp.name))
		end
	end
end

function bindPowerKeysForPlayer(player)
    bindKey(player, "Z", "up", powerButtonPressed)
	bindKey(player, "X", "up", powerButtonPressed)
	bindKey(player, "C", "up", powerButtonPressed)
	bindKey(player, "lctrl", "up", powerButtonPressed)
end

function unbindPowerKeysForPlayer(player)
    unbindKey(player, "Z")
	unbindKey(player, "X")
	unbindKey(player, "C")
	unbindKey(player, "lctrl")
end

function bindThePowerKeys ( )
    bindPowerKeysForPlayer(source)
end
addEventHandler("onPlayerJoin", getRootElement(), bindThePowerKeys)

  --unbind on quit
function unbindThePowerKeys ( )
    unbindPowerKeysForPlayer(source)
end
addEventHandler("onPlayerQuit", getRootElement(), unbindThePowerKeys)

function bindPowerKeysOnStart()
    for k, player in ipairs(getElementsByType("player")) do
        bindPowerKeysForPlayer(player)
    end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), bindPowerKeysOnStart)

function unbindPowerKeysOnStop()
    for k, player in ipairs(getElementsByType("player")) do
        unbindPowerKeysForPlayer(player)
    end
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), unbindPowerKeysOnStop)