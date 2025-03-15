local nitroPowerUp = {
	key = "nitro",
	name = "Nitro",
	desc = "Nitro is a powerup that gives you a speed boost for a short period of time. It can be activated by pressing the left control key.",
	bindKey = "lctrl",
	cooldown = function() return getPowerConst().nitro.cooldown end,
	duration = function() return getPowerConst().nitro.duration end,
	initCooldown = function() return getPowerConst().nitro.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().nitro.allowedGoldCarrier end,
	charges = function() return getPowerConst().nitro.charges end,
	rank = function() return getPowerConst().nitro.rank end,
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
	cooldown = function() return getPowerConst().teleport.cooldown end,
	duration = function() return getPowerConst().teleport.duration end,
	initCooldown = function() return getPowerConst().teleport.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().teleport.allowedGoldCarrier end,
	charges = function() return getPowerConst().teleport.charges end,
	rank = function() return getPowerConst().teleport.rank end,
	onEnable = function(player, vehicle)
		-- outputChatBox("teleport enabled "..getPlayerName(player))
		if isFarEnoughFromLeader(player) then
			return true
		else
			return {
				pollTime = 5,
				message = "Too close to leader"
			}
		end
	end,
	onDisable = function(player, vehicle)
	end,
	onActivated = function(player, vehicle)
		-- askForTeleport(player)
		spawnCloseToMeanPositionOfAllPlayers(player)
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

local NOTIFY_POWER_ACTIVATED_KEY = 8914555
function notifyPowerActivated(player, powerUpName)
	displayMessageForAll(NOTIFY_POWER_ACTIVATED_KEY, getPlayerName(player).." activated "..powerUpName, player, "", 3000, 0.5, 0.3, 255, 100, 0, 2 )
end

function resetPowerStatesOnDeliverd()
	for i, player in ipairs(getElementsByType("player")) do
		local config = getPlayerPowerConfig(player)
		--outputServerLog("Setting completed rank "..inspect(config).." "..inspect(config.usedRank))
		setCompletedRank(player, getUsedRank(player))
		resetPowerStatesForPlayer(player)
	end
end

function resetPowerStatesForPlayer(player)
	local powerConfig = getPlayerPowerConfig(player)
	for j, powerUpConfig in ipairs(powerConfig.active) do
		local powerUp = findPowerUpWithKey(powerUpConfig.key)
		--outputServerLog("resetPowerStatesForPlayer "..inspect(player).." "..inspect(powerUp).." "..inspect(powerUpConfig))
		if powerUp then
			resetPowerState(player, powerUp)
		else
			outputServerLog("PowerUp not found "..inspect(powerUpConfig.key))
		end
	end
end

function handlePowersForGoldCarrierChanged(newGoldCarrier, oldGoldCarrier)
	if oldGoldCarrier and newGoldCarrier then
		loopOverPowersForPlayer(oldGoldCarrier, function(player, powerUp, powerUpState, powerConfig)
			if not powerUp.allowedGoldCarrier() then
				unpausePower(player, powerUp, powerUpState)
			end
		end)
	end

	if newGoldCarrier then
	loopOverPowersForPlayer(newGoldCarrier, function(player, powerUp, powerUpState, powerConfig)
			if not powerUp.allowedGoldCarrier() then
				pausePower(player, powerUp, powerUpState)
			end
		end)
	end
end

local stateEnum = {
	READY = 1,
	COOLDOWN = 2,
	IN_USE = 3,
	OUT_OF_CHARGES = 4,
	PAUSED = 5,
	WAITING = 6
}

function endActivePowers(player, powerUp, powerUpState)
	if powerUpState then
		if powerUpState.timer then
			killPowerTimer(powerUpState)
			powerUpState.timer = nil
		end
	end

	if powerUpState and powerUpState.state == stateEnum.PAUSED then
		unpausePower(player, powerUp, powerUpState)
	end

	if powerUpState and (powerUpState.state == stateEnum.IN_USE or powerUpState.state == stateEnum.READY) then
		local vehicle = getPedOccupiedVehicle (player)
		if vehicle then
			powerUp.onDeactivated(player, vehicle)
		end
	end
end

function resetPowerState(player, powerUp)
	local playerName = getPlayerName(player)
	local states = powerUpStates[powerUp.key]

	-- get old state and kill timer
	local powerUpState = states[playerName]
	endActivePowers(player, powerUp, powerUpState)

	powerUpState = {
		state = stateEnum.READY,
		endTime = nil,
		timeLeftOnPause = nil,
		stateMessage = nil,
		stateBeforePause = nil,
		charges = powerUp.charges(),
		name = powerUp.name,
		timer = nil
	}
	if powerUp.initCooldown() > 0 then
-- outputServerLog("initCooldown "..inspect(powerUp.initCooldown()))
		setStateWithTimer(stateEnum.COOLDOWN, powerUp.initCooldown(), powerUpState, player, powerUp)
	else
-- outputServerLog("initCooldown 0")
		setState(powerUp, player, stateEnum.READY, "Ready", powerUpState, nil)
	end
	states[playerName] = powerUpState
	return powerUpState
end

function killPowerTimer(state)
	--outputServerLog("killPowerTimer "..inspect(state.name).." "..inspect(state.state))
	if state.timer then
		killTimer(state.timer)
		state.timer = nil
	end
end

function pausePower(player, powerUp, powerUpState)
	-- switch case for state values
	if powerUpState.state == stateEnum.COOLDOWN then
		powerUpState.timeLeftOnPause = timeLeft(powerUpState)
		powerUpState.stateBeforePause = stateEnum.COOLDOWN
	elseif powerUpState.state == stateEnum.IN_USE then
		powerUpState.timeLeftOnPause = timeLeft(powerUpState)
		powerUpState.stateBeforePause = stateEnum.IN_USE
	elseif powerUpState.state == stateEnum.READY then
		powerUpState.stateBeforePause = stateEnum.READY
	elseif powerUpState.state == stateEnum.OUT_OF_CHARGES then
		powerUpState.stateBeforePause = stateEnum.OUT_OF_CHARGES
	elseif powerUpState.state == stateEnum.WAITING then
		powerUpState.stateBeforePause = stateEnum.WAITING
		powerUpState.timeLeftOnPause = timeLeft(powerUpState)
	elseif powerUpState.state == stateEnum.PAUSED then
		-- do nothing
	end

	setState(powerUp, player, stateEnum.PAUSED, "Paused while leading", state, nil)
	local vehicle = getPedOccupiedVehicle (player)
	if vehicle then
		powerUp.onDeactivated(player, vehicle)
	end
	-- kill timer
	killPowerTimer(powerUpState)
end

function unpausePower(player, powerUp, powerUpState)
	killPowerTimer(powerUpState)
	if powerUpState.state == stateEnum.PAUSED then
		if powerUpState.stateBeforePause == stateEnum.COOLDOWN then
			setStateWithTimer(stateEnum.COOLDOWN, powerUpState.timeLeftOnPause, powerUpState, player, powerUp)
		elseif powerUpState.stateBeforePause == stateEnum.IN_USE then
			setStateWithTimer(stateEnum.IN_USE, powerUpState.timeLeftOnPause, powerUpState, player, powerUp)
		elseif powerUpState.stateBeforePause == stateEnum.WAITING then
			setStateWithTimer(stateEnum.WAITING, powerUpState.timeLeftOnPause, powerUpState, player, powerUp)
		elseif powerUpState.stateBeforePause == stateEnum.READY then
			tryEnablePower(powerUp, powerUpState, player)
		elseif powerUpState.stateBeforePause == stateEnum.OUT_OF_CHARGES then
			setState(powerUp, player, stateEnum.OUT_OF_CHARGES, "Out of charges", state, nil)
		end
	end

	powerUpState.timeLeftOnPause = nil
	powerUpState.stateBeforePause = nil
end

function setEndsTime(duration, state)
	local time = getRealTime()
	local endsTime = time.timestamp + duration
	state.endTime = endsTime
end

function tryEnablePower(powerUp, powerUpState, player)
	local vehicle = getPedOccupiedVehicle (player)
	if not vehicle then
		setStateWithTimer(stateEnum.WAITING, 2000, powerUpState, player, powerUp, "Waiting for vehicle")
	end

	local wasEnabledOrWaitTime = powerUp.onEnable(player, vehicle)
	if (wasEnabledOrWaitTime) then
		setState(powerUp, player, stateEnum.READY, "Ready", powerUpState, nil)
		powerUpState.endTime = nil
	else
		setStateWithTimer(stateEnum.WAITING, wasEnabledOrWaitTime.pollTime, powerUpState, player, powerUp, wasEnabledOrWaitTime.message)
	end
end

function tryDeactivatePower(powerUp, powerUpState, player)
	local vehicle = getPedOccupiedVehicle (player)
	if vehicle then
		powerUp.onDeactivated(player, vehicle, powerUpState)
	end

	if powerUpState.charges and powerUpState.charges <= 0 then
		setState(powerUp, player, stateEnum.OUT_OF_CHARGES, "Out of charges", state, nil)
	else
		setStateWithTimer(stateEnum.COOLDOWN, powerUp.cooldown(), powerUpState, player, powerUp)
	end
end

function timerDone(player, powerUpKey)
	local powerUp = findPowerUpWithKey(powerUpKey)
	--outputServerLog("timerDone "..inspect(player))
	local powerUpState = getPlayerState(player, powerUp)
	killPowerTimer(powerUpState)
	if powerUpState.state == stateEnum.COOLDOWN then
		tryEnablePower(powerUp, powerUpState, player)
	elseif powerUpState.state == stateEnum.IN_USE then
		tryDeactivatePower(powerUp, powerUpState, player)
	elseif powerUpState.state == stateEnum.WAITING then
		tryEnablePower(powerUp, powerUpState, player, vehicle)
	end
end

function setStateWithTimer(stateType, duration, state, player, powerUp, message)
	setEndsTime(duration, state)
	setState(powerUp, player, stateType, message, state, nil)
	local seconds = timeLeft(state)

	if seconds <= 0 then
-- outputServerLog("Timer not needed for "..inspect(player).." "..inspect(powerUp.key))
		timerDone(player, powerUp.key)
		return
	end

	--outputServerLog("Timer starting "..inspect(player).." "..inspect(powerUp.key))
	state.timer = setTimer(function()
-- outputServerLog("Timer done inside "..inspect(player).." "..inspect(powerUp.key))
		timerDone(player, powerUp.key)
	end, seconds * 1000, 1)
end

function timeLeft(powerUpState)
	local currentTime = getRealTime()
	if not powerUpState.endTime then
		return 0
	end
	return powerUpState.endTime - currentTime.timestamp
end

function getPlayerState(player, powerUp)
	local states = powerUpStates[powerUp.key]
	local playerName = getPlayerName(player)
	local powerUpState = states[playerName]
	if (not powerUpState) then
		powerUpStates[powerUp.key] = {}
		powerUpState = resetPowerState(player, powerUp)
	end
	return powerUpState
end

function setState(powerUp, player, stateType, stateMessage, state, config)
	if not config then
		local powerConfig = getPlayerPowerConfig(player)
		for j, powerUpConfig in ipairs(powerConfig.active) do
			if powerUpConfig.key == powerUp.key then
				config = powerUpConfig
				break
			end
		end
	end
	
	if not state then
-- outputServerLog("setState "..inspect(player))
		state = getPlayerState(player, powerUp)
	end

	local oldState = state.state
	state.state = stateType
	state.stateMessage = stateMessage
	local totalCharges = 0
	if powerUp.charges() and powerUp.charges() > 0 then
		totalCharges = powerUp.charges()
	end
	triggerClientEvent(player, "powerupStateChangedClient", player, stateType, oldState, powerUp.name, stateMessage, config.bindKey, state.charges, totalCharges, timeLeft(state))
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
		local charges = nil
		if powerUp.charges then
			charges = powerUp.charges()
		end
		table.insert(data, {
			key = powerUp.key,
			name = powerUp.name,
			desc = powerUp.desc,
			bindKey = powerUp.bindKey,
			cooldown = powerUp.cooldown(),
			duration = powerUp.duration(),
			charges = charges,
			initCooldown = powerUp.initCooldown(),
			allowedGoldCarrier = powerUp.allowedGoldCarrier(),
			rank = powerUp.rank()
		})
	end
	return data
end

function usePowerUp(player, key, keyState, powerUp)
	--outputServerLog("usePowerUp "..getPlayerName(player).." "..powerUp.name.." "..key.." "..keyState)
	-- outputChatBox("usePowerUp "..getPlayerName(player).." "..powerUp.name.." "..key.." "..keyState)
	
	local state = getPlayerState(player, powerUp)
	--outputServerLog("usePowerUp "..inspect(player)..inspect(state.state)..inspect(stateEnum.READY).." "..inspect(state.state == stateEnum.READY))
	if not (state.state == stateEnum.READY) then
-- outputServerLog("returns")
-- outputChatBox("Power not ready yet: "..inspect(powerUp.name))
		return
	else
-- outputServerLog("continues")
	end

	setStateWithTimer(stateEnum.IN_USE, powerUp.duration(), state, player, powerUp, "In use")
	if state.charges and state.charges > 0 then
		state.charges = state.charges - 1
	end
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

function loopOverPowersForPlayer(player, callback)
	local powerConfig = getPlayerPowerConfig(player)
	for j, powerUpConfig in ipairs(powerConfig.active) do
		local powerUp = findPowerUpWithKey(powerUpConfig.key)
		if powerUp == nil then
	-- outputServerLog("powerUp is nil "..inspect(powerUpConfig.key))
			break
		end
-- outputServerLog("loopOverPowersForPlayer "..inspect(player))
		local powerUpState = getPlayerState(player, powerUp)
		if not powerUpState then
	-- outputServerLog("powerUpState is nil "..inspect(powerUpConfig.key))
			break
		end
		callback(player, powerUp, powerUpState, powerConfig)
	end
end

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
	-- outputServerLog("powerButtonPressed "..inspect(player))
			powerUpState = getPlayerState(player, powerUp)
		end
	else 
-- outputChatBox("No power bound for button: "..button)
	end

	if powerUpState then
	 	usePowerUp(player, button, powerUpState, powerUp)
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
	resetPowerStatesForPlayer(source)
end
addEventHandler("onPlayerJoin", getRootElement(), bindThePowerKeys)

  --unbind on quit
function unbindThePowerKeys ( )
    unbindPowerKeysForPlayer(source)
	loopOverPowersForPlayer(source, function(player, powerUp, powerUpState, powerConfig)
		endActivePowers(player, powerUp, powerUpState)
	end)
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