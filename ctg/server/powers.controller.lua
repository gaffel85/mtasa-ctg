local nitroPowerUp = {
	key = "nitro",
	name = "Nitro",
	desc = "Nitro is a powerup that gives you a speed boost for a short period of time. It can be activated by pressing the left control key.",
	bindKey = "lctrl",
	resourceKey = "energy",
	burnRate = 15,
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

local powers = {}
local powerStates = {}

function addPowerUp(powerUp)
	--outputServerLog("Adding powerup "..inspect(powerUp))
	--table.insert(powerUps, powerUp)
	--powerUpStates[powerUp.key] = {}
end

function addResourcePower(powerUp)
    table.insert(powers, powerUp)
end

addResourcePower(nitroPowerUp)

function getPlayerPowerConfig2(player)
    return {
        active = {
            { key = "nitro", bindKey = "C" },
        }
    }
end

function resetPowerStatesOnDeliverd()
	for i, player in ipairs(getElementsByType("player")) do
		setCompletedRank(player, getUsedRank(player))
		resetPowerStatesForPlayer2(player)
	end
end

function resetPowerStatesForPlayer2(player)
	local powerConfig = getPlayerPowerConfig(player)
	for j, powerUpConfig in ipairs(powerConfig.active) do
		local powerUp = findPowerUpWithKey2(powerUpConfig.key)
		--outputServerLog("resetPowerStatesForPlayer "..inspect(player).." "..inspect(powerUp).." "..inspect(powerUpConfig))
		if powerUp then
			resetPowerState2(player, powerUp)
		else
			outputServerLog("PowerUp not found "..inspect(powerUpConfig.key))
		end
	end
end

function handlePowersForGoldCarrierChanged(newGoldCarrier, oldGoldCarrier)
	if oldGoldCarrier and newGoldCarrier then
		loopOverPowersForPlayer2(oldGoldCarrier, function(player, powerUp, powerUpState, powerConfig)
			if not powerUp.allowedGoldCarrier() then
				unpausePower2(player, powerUp, powerUpState)
			end
		end)
	end

	if newGoldCarrier then
	loopOverPowersForPlayer2(newGoldCarrier, function(player, powerUp, powerUpState, powerConfig)
			if not powerUp.allowedGoldCarrier() then
				pausePower2(player, powerUp, powerUpState)
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

function getStateEnum()
    return stateEnum
end

function endActivePowers2(player, powerUp, powerUpState)
	if powerUpState then
		if powerUpState.timer then
			killPowerTimer(powerUpState)
			powerUpState.timer = nil
		end
	end

	if powerUpState and powerUpState.state == stateEnum.PAUSED then
		unpausePower2(player, powerUp, powerUpState)
	end

	if powerUpState and (powerUpState.state == stateEnum.IN_USE or powerUpState.state == stateEnum.READY) then
		local vehicle = getPedOccupiedVehicle (player)
		if vehicle then
			powerUp.onDeactivated(player, vehicle)
		end
	end
end

function resetPowerState2(player, powerUp)
    local playerState = powerStates[player]
	if not playerState then
		playerState = {}
		powerStates[player] = playerState
	end

	-- get old state and kill timer
	local powerUpState = playerState[powerUp.key]
	endActivePowers2(player, powerUp, powerUpState)

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
		setStateWithTimer2(stateEnum.COOLDOWN, powerUp.initCooldown(), powerUpState, player, powerUp)
	else
-- outputServerLog("initCooldown 0")
		setState2(powerUp, player, stateEnum.READY, "Ready", powerUpState, nil)
	end
	playerState[powerUp.key] = powerUpState
	return powerUpState
end

function killPowerTimer2(state)
	--outputServerLog("killPowerTimer "..inspect(state.name).." "..inspect(state.state))
	if state.timer then
		killTimer(state.timer)
		state.timer = nil
	end
end

function pausePower2(player, powerUp, powerUpState)
	-- switch case for state values
	if powerUpState.state == stateEnum.COOLDOWN then
		powerUpState.timeLeftOnPause = timeLeft2(powerUpState)
		powerUpState.stateBeforePause = stateEnum.COOLDOWN
	elseif powerUpState.state == stateEnum.IN_USE then
		powerUpState.timeLeftOnPause = timeLeft2(powerUpState)
		powerUpState.stateBeforePause = stateEnum.IN_USE
	elseif powerUpState.state == stateEnum.READY then
		powerUpState.stateBeforePause = stateEnum.READY
	elseif powerUpState.state == stateEnum.OUT_OF_CHARGES then
		powerUpState.stateBeforePause = stateEnum.OUT_OF_CHARGES
	elseif powerUpState.state == stateEnum.WAITING then
		powerUpState.stateBeforePause = stateEnum.WAITING
		powerUpState.timeLeftOnPause = timeLeft2(powerUpState)
	elseif powerUpState.state == stateEnum.PAUSED then
		-- do nothing
	end

	setState2(powerUp, player, stateEnum.PAUSED, "Paused while leading", state, nil)
	local vehicle = getPedOccupiedVehicle (player)
	if vehicle then
		powerUp.onDeactivated(player, vehicle)
	end
	-- kill timer
	killPowerTimer2(powerUpState)
end

function unpausePower2(player, powerUp, powerUpState)
	killPowerTimer2(powerUpState)
	if powerUpState.state == stateEnum.PAUSED then
		if powerUpState.stateBeforePause == stateEnum.COOLDOWN then
			setStateWithTimer2(stateEnum.COOLDOWN, powerUpState.timeLeftOnPause, powerUpState, player, powerUp)
		elseif powerUpState.stateBeforePause == stateEnum.IN_USE then
			setStateWithTimer2(stateEnum.IN_USE, powerUpState.timeLeftOnPause, powerUpState, player, powerUp)
		elseif powerUpState.stateBeforePause == stateEnum.WAITING then
			setStateWithTimer2(stateEnum.WAITING, powerUpState.timeLeftOnPause, powerUpState, player, powerUp)
		elseif powerUpState.stateBeforePause == stateEnum.READY then
			tryEnablePower2(powerUp, powerUpState, player)
		elseif powerUpState.stateBeforePause == stateEnum.OUT_OF_CHARGES then
			setState2(powerUp, player, stateEnum.OUT_OF_CHARGES, "Out of charges", state, nil)
		end
	end

	powerUpState.timeLeftOnPause = nil
	powerUpState.stateBeforePause = nil
end

function setEndsTime2(duration, state)
	local time = getRealTime()
	local endsTime = time.timestamp + duration
	state.endTime = endsTime
end

function tryEnablePower2(powerUp, powerUpState, player)
	local vehicle = getPedOccupiedVehicle (player)
	if not vehicle then
		setStateWithTimer2(stateEnum.WAITING, 2000, powerUpState, player, powerUp, "Waiting for vehicle")
	end

	local wasEnabledOrWaitTime = powerUp.onEnable(player, vehicle)
	if (wasEnabledOrWaitTime) then
		setState2(powerUp, player, stateEnum.READY, "Ready", powerUpState, nil)
		powerUpState.endTime = nil
	else
		setStateWithTimer2(stateEnum.WAITING, wasEnabledOrWaitTime.pollTime, powerUpState, player, powerUp, wasEnabledOrWaitTime.message)
	end
end

function tryDeactivatePower2(powerUp, powerUpState, player)
	local vehicle = getPedOccupiedVehicle (player)
	if vehicle then
		powerUp.onDeactivated(player, vehicle, powerUpState)
	end

	if powerUpState.charges and powerUpState.charges <= 0 then
		setState2(powerUp, player, stateEnum.OUT_OF_CHARGES, "Out of charges", state, nil)
	else
        setState2(powerUp, player, stateEnum.READY, "Ready", powerUpState, nil)
		--setStateWithTimer2(stateEnum.COOLDOWN, powerUp.cooldown(), powerUpState, player, powerUp)
	end
end

function timerDone2(player, powerUpKey)
	local powerUp = findPowerUpWithKey2(powerUpKey)
	--outputServerLog("timerDone "..inspect(player))
	local powerUpState = getPlayerState2(player, powerUp)
	killPowerTimer2(powerUpState)
	if powerUpState.state == stateEnum.COOLDOWN then
		tryEnablePower2(powerUp, powerUpState, player)
	elseif powerUpState.state == stateEnum.IN_USE then
        resetResouceAmount(player, powerUp.resourceKey)
		tryDeactivatePower2(powerUp, powerUpState, player)
	elseif powerUpState.state == stateEnum.WAITING then
		tryEnablePower2(powerUp, powerUpState, player, vehicle)
	end
end

function timeForFullResourceBurn(player, powerUp)
    local resourceState = getResourceState(powerUp.resourceKey)
    local maxSeconds = resourceState.amount / powerUp.burnRate
    return maxSeconds
end

function setStateWithTimer2(stateType, duration, state, player, powerUp, message)
	setEndsTime2(duration, state)
	setState2(powerUp, player, stateType, message, state, nil)
	local seconds = timeLeft2(state)

	if seconds <= 0 then
-- outputServerLog("Timer not needed for "..inspect(player).." "..inspect(powerUp.key))
		timerDone2(player, powerUp.key)
		return
	end

	--outputServerLog("Timer starting "..inspect(player).." "..inspect(powerUp.key))
	state.timer = setTimer(function()
-- outputServerLog("Timer done inside "..inspect(player).." "..inspect(powerUp.key))
		timerDone2(player, powerUp.key)
	end, seconds * 1000, 1)
end

function timeLeft2(powerUpState)
	local currentTime = getRealTime()
	if not powerUpState.endTime then
		return 0
	end
	return powerUpState.endTime - currentTime.timestamp
end

function getPlayerState2(player, powerUp)
    local playerStates = powerStates[player]
	local powerUpState = playerStates[powerUp.key]
	if (not powerUpState) then
		powerUpState = resetPowerState2(player, powerUp)
	end
	return powerUpState
end

function setState2(powerUp, player, stateType, stateMessage, state)
    local powerConfig = getPlayerPowerConfig2(player)
    local config = nil
    for j, powerUpConfig in ipairs(powerConfig.active) do
        if powerUpConfig.key == powerUp.key then
            config = powerUpConfig
            break
        end
    end

    if not config then
        outputServerLog("Could not find config for powerUp "..inspect(powerUp.key))
        return
    end
	
	if not state then
-- outputServerLog("setState "..inspect(player))
		state = getPlayerState2(player, powerUp)
	end

	local oldState = state.state
	state.state = stateType
	state.stateMessage = stateMessage
	local totalCharges = 0
	if powerUp.charges() and powerUp.charges() > 0 then
		totalCharges = powerUp.charges()
	end
	triggerClientEvent(player, "powerupStateChangedClient", player, stateType, oldState, powerUp.name, stateMessage, config.bindKey, state.charges, totalCharges, timeLeft2(state))
end

function findPowerUpWithKey2(key)
	for i, powerUp in ipairs(powers) do
		if (powerUp.key == key) then
			return powerUp
		end
	end
	return nil
end

function getPowerUps2()
	return powers
end

function getPowerUpsData2()
	local data = {}
	for i, powerUp in ipairs(powers) do
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

function usePowerUp2(player, key, keyState, powerUp)
	--outputServerLog("usePowerUp "..getPlayerName(player).." "..powerUp.name.." "..key.." "..keyState)
	-- outputChatBox("usePowerUp "..getPlayerName(player).." "..powerUp.name.." "..key.." "..keyState)
	
	local state = getPlayerState2(player, powerUp)
	--outputServerLog("usePowerUp "..inspect(player)..inspect(state.state)..inspect(stateEnum.READY).." "..inspect(state.state == stateEnum.READY))
	if not (state.state == stateEnum.READY) then
-- outputServerLog("returns")
-- outputChatBox("Power not ready yet: "..inspect(powerUp.name))
		return
	else
-- outputServerLog("continues")
	end

    local calculateMaxDuration = timeForFullResourceBurn(player, powerUp)

	setStateWithTimer2(stateEnum.IN_USE, calculateMaxDuration, state, player, powerUp, "In use")
	if state.charges and state.charges > 0 then
		state.charges = state.charges - 1
	end
	-- outputChatBox("state: "..tostring(state.activated))
	--outputServerLog("state: "..inspect(state))
	local vehicle = getPedOccupiedVehicle(player)
	if (vehicle) then
		local realPowerUp = findPowerUpWithKey2(powerUp.key)
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

function loopOverPowersForPlayer2(player, callback)
	local powerConfig = getPlayerPowerConfig2(player)
	for j, powerUpConfig in ipairs(powerConfig.active) do
		local powerUp = findPowerUpWithKey2(powerUpConfig.key)
		if powerUp == nil then
	-- outputServerLog("powerUp is nil "..inspect(powerUpConfig.key))
			break
		end
-- outputServerLog("loopOverPowersForPlayer "..inspect(player))
		local powerUpState = getPlayerState2(player, powerUp)
		if not powerUpState then
	-- outputServerLog("powerUpState is nil "..inspect(powerUpConfig.key))
			break
		end
		callback(player, powerUp, powerUpState, powerConfig)
	end
end

addEvent("loadPowerUpsServer", true)
addEventHandler("loadPowerUpsServer", root, function()
	local data = getPowerUpsData2()
	--triggerClientEvent("onPowerupsLoadedClient", getRootElement(), data)
	triggerClientEvent(client, "onPowerupsLoadedClient", this, data)
	--triggerClientEvent(source, "onPowerupsLoadedClient", this, data)
end)

--addPowerUp(nitroPowerUp)
--addPowerUp(teleportPowerUp)

function powerButtonPressed(player, button)
	local powerConfig = getPlayerPowerConfig2(player)
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
		powerUp = findPowerUpWithKey2(powerForBoundKey.key)
		if (powerUp) then
	-- outputServerLog("powerButtonPressed "..inspect(player))
			powerUpState = getPlayerState2(player, powerUp)
		end
	else 
-- outputChatBox("No power bound for button: "..button)
	end

	if powerUpState then
	 	usePowerUp2(player, button, powerUpState, powerUp)
	end
end

function powerKeyDown(player, key, keyState)
    powerButtonPressed(player, key)
end

function powerKeyUp(player, key, keyState)
    for i, powerUp in ipairs(powers) do
        --powerUp(player)
    end
end

function emptyPowerState(power)
    return {
        power = power.key,
        active = false
    }
end

addEventHandler("onPlayerJoin", getRootElement(), function()
	powerStates[source] = {}
    resetPowerStatesForPlayer2(source)
end)
  --unbind on quit

addEventHandler("onPlayerQuit", getRootElement(), function()
	loopOverPowersForPlayer(source, function(player, powerUp, powerUpState, powerConfig)
		endActivePowers(player, powerUp, powerUpState)
	end)
    powerStates[source] = nil
end)

registerBindFunctions(function(player)
    bindKey(player, "C", "down", powerKeyDown)
    bindKey(player, "C", "up", powerKeyUp)
end, function(player)
    unbindKey(player, "C", "down", powerKeyDown)
    unbindKey(player, "C", "up", powerKeyUp)
end)