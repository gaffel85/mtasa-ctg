local nitroPowerUp = {
	key = "nitro",
	name = "Nitro",
	desc = "Nitro is a powerup that gives you a speed boost for a short period of time. It can be activated by pressing the left control key.",
	bindKey = "lctrl",
	resourceKey = "energy",
	burnRate = 15,
	minResourceAmount = 30,
	cooldown = function() return getPowerConst().nitro.cooldown end,
	duration = function() return getPowerConst().nitro.duration end,
	initCooldown = function() return getPowerConst().nitro.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().nitro.allowedGoldCarrier end,
	charges = function() return getPowerConst().nitro.charges end,
	rank = function() return getPowerConst().nitro.rank end,
	onEnable = function(player, vehicle)
		outputChatBox("Nitro enabled "..getPlayerName(player))
		addVehicleUpgrade(vehicle, 1009)
		return true
	end,
	onDisable = function(player, vehicle)
		outputChatBox("Nitro onDisabled"..getPlayerName(player))
		removeVehicleUpgrade(vehicle, 1009)
	end,
	onActivated = function(player, vehicle)
		outputChatBox("Nitro activated"..getPlayerName(player))
		setVehicleNitroActivated(vehicle, true)
	end,
	onDeactivated = function(player, vehicle)
		outputChatBox("Nitro deactivated"..getPlayerName(player))
		setVehicleNitroActivated(vehicle, false)
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
            --{ key = "nitro", bindKey = "C", toggle = true },
			{ key = "nitro", bindKey = "mouse1", toggle = false },
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
	--if powerUp.initCooldown() > 0 then
-- outputServerLog("initCooldown "..inspect(powerUp.initCooldown()))
		--setStateWithTimer2(stateEnum.COOLDOWN, powerUp.initCooldown(), powerUpState, player, powerUp)
	--else
-- outputServerLog("initCooldown 0")
	-- setState2(powerUp, player, stateEnum.READY, "Ready", powerUpState, nil)
	tryEnablePower2(powerUp, powerUpState, player)
	--end
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
		outputServerLog("1")
		setStateWithTimer2(stateEnum.WAITING, 2, powerUpState, player, powerUp, "Waiting for vehicle")
		return
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
	outputServerLog("3")
	local vehicle = getPedOccupiedVehicle (player)
	if vehicle then
		powerUp.onDeactivated(player, vehicle, powerUpState)
	end

	outputServerLog("4")
	if powerUpState.charges and powerUpState.charges <= 0 then
		setState2(powerUp, player, stateEnum.OUT_OF_CHARGES, "Out of charges", state, nil)
	else
		outputServerLog("5")
        setState2(powerUp, player, stateEnum.READY, "Ready", powerUpState, nil)
		--setStateWithTimer2(stateEnum.COOLDOWN, powerUp.cooldown(), powerUpState, player, powerUp)
	end
end

function timerDone2(player, powerUpKey)
	local powerUp = findPowerUpWithKey2(powerUpKey)
	outputServerLog("timerDone "..inspect(getPlayerName(player)))
	local powerUpState = getPlayerState2(player, powerUp)
	killPowerTimer2(powerUpState)
	outputServerLog("timerDone2 "..inspect(powerUpState.state))
	if powerUpState.state == stateEnum.COOLDOWN then
		tryEnablePower2(powerUp, powerUpState, player)
	elseif powerUpState.state == stateEnum.IN_USE then
		endUsePower(player, powerUp, powerUpState)
	elseif powerUpState.state == stateEnum.WAITING then
		outputServerLog("tryEnablePower2 after waiting")
		tryEnablePower2(powerUp, powerUpState, player)
	end
end

function timeForFullResourceBurn(player, powerUp)
    local resourceState = getResourceState(player, powerUp.resourceKey)
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

	outputServerLog("setStateWithTimer2 "..inspect(seconds))
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
	--outputServerLog("getPlayerState2 "..inspect(getPlayerName(player)).." "..inspect(powerUp))
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
		outputServerLog("setState "..inspect(getPlayerName(player)))
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

function findPowerWithResource(resourceKey)
	for i, powerUp in ipairs(powers) do
		if (powerUp.resourceKey == resourceKey) then
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

function endUsePower(player, powerUp, powerUpState)
	outputServerLog("endUsePower "..inspect(getPlayerName(player)).." "..inspect(powerUp.key).." "..inspect(powerUpState.state))
	if powerUpState.state ~= stateEnum.IN_USE then
		return
	end
	resetResouceAmount(player, powerUp.resourceKey)
	tryDeactivatePower2(powerUp, powerUpState, player)
	tryEnablePower2(powerUp, powerUpState, player)
	triggerClientEvent(player, "resourceNotInUseFromServer", getRootElement(), powerUp.resourceKey, 0)
end

function usePowerUp2(player, key, keyState, powerUp)
	--outputServerLog("usePowerUp "..getPlayerName(player).." "..powerUp.name.." "..key.." "..keyState)
	--outputChatBox("usePowerUp "..getPlayerName(player).." "..inspect(powerUp))
	
	local state = getPlayerState2(player, powerUp)
	outputServerLog("usePowerUp "..inspect(getPlayerName(player)).." "..inspect(powerUp.resourceKey))
	local resourceState = getResourceState(player, powerUp.resourceKey)
	outputServerLog("Resource "..inspect(powerUp.resourceKey).." "..inspect(resourceState.amount))
	if resourceState.amount < powerUp.minResourceAmount then
		return
	end
	--outputServerLog("usePowerUp "..inspect(player)..inspect(state.state)..inspect(stateEnum.READY).." "..inspect(state.state == stateEnum.READY))
	if not (state.state == stateEnum.READY) then
		-- outputServerLog("returns")
		outputChatBox("Power not ready yet: "..inspect(powerUp.name))
		return
	end

    local calculateMaxDuration = timeForFullResourceBurn(player, powerUp)

	setStateWithTimer2(stateEnum.IN_USE, calculateMaxDuration, state, player, powerUp, "In use")
	triggerClientEvent(player, "resourceInUseFromServer", getRootElement(), powerUp.resourceKey, powerUp.burnRate)
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
			outputServerLog("powerUp is nil "..inspect(powerUpConfig.key))
			break
		end
		--outputServerLog("loopOverPowersForPlayer "..inspect(getPlayerName(player)))
		local powerUpState = getPlayerState2(player, powerUp)
		if not powerUpState then
			outputServerLog("powerUpState is nil "..inspect(powerUpConfig.key))
			break
		end
		callback(player, powerUp, powerUpState, powerConfig)
	end
end

addEventHandler("energyAmountChangedFromClient", resourceRoot, function(key, amount, secondsUntilEnd, isBurning, burnRate, fillRate)
    outputServerLog("energy from client "..inspect(key).." "..inspect(amount).." "..inspect(secondsUntilEnd).." "..inspect(isBurning).." "..inspect(burnRate).." "..inspect(fillRate))
	if isBurning then
		local powerUp = findPowerWithResource(key)
		local powerUpState = getPlayerState2(source, powerUp)
		if not powerUpState then
			outputServerLog("powerUpState is nil "..inspect(powerUp.key))
			return
		end
		killPowerTimer2(powerUpState)
		setStateWithTimer2(stateEnum.IN_USE, secondsUntilEnd, powerUpState, source, powerUp)
	end
end)

addEvent("loadPowerUpsServer", true)
addEventHandler("loadPowerUpsServer", root, function()
	local data = getPowerUpsData2()
	--triggerClientEvent("onPowerupsLoadedClient", getRootElement(), data)
	triggerClientEvent(client, "onPowerupsLoadedClient", this, data)
	--triggerClientEvent(source, "onPowerupsLoadedClient", this, data)
end)

--addPowerUp(nitroPowerUp)
--addPowerUp(teleportPowerUp)

function powerForButton(player, button)
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
			--outputServerLog("powerButtonPressed "..inspect(powerUp))
			powerUpState = getPlayerState2(player, powerUp)
		end
	else 
-- outputChatBox("No power bound for button: "..button)
	end
	return powerUp, powerUpState, powerForBoundKey
end

--[[function powerButtonPressed(player, button, buttonState)
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
			outputServerLog("powerButtonPressed "..inspect(getPlayerName(player)))
			powerUpState = getPlayerState2(player, powerUp)
		end
	else 
-- outputChatBox("No power bound for button: "..button)
	end

	if powerUpState then
	 	usePowerUp2(player, button, powerUpState, powerUp)
	end
end
]]--

function powerKeyDown(player, button, keyState)
	local power, powerState, powerConfig = powerForButton(player, button)
	if not power or not powerState then
		outputServerLog("No power found for button: "..button)
		return
	end

	-- outputServerLog("powerKeyDown Is toggle: "..inspect(powerConfig))
	if powerConfig.toggle then
		outputServerLog("Is toggle, doing nothing")	
	else
		outputServerLog("Is not toggle, starting power")
		usePowerUp2(player, button, buttonState, power)
	end
end

function powerKeyUp(player, button, keyState)
    local power, powerState, powerConfig = powerForButton(player, button)
	if not power or not powerState then
		outputServerLog("No power found for button: "..button)
		return
	end
	
	-- outputServerLog("powerKeyUp Is toggle: "..inspect(powerConfig))
	if powerConfig.toggle then
		if powerState.state == stateEnum.IN_USE then
			outputServerLog("Is in use, ending power")
			endUsePower(player, power, powerState)
		else
			outputServerLog("Is not in use, starting power")
			usePowerUp2(player, button, buttonState, power)
		end
	else
		endUsePower(player, power, powerState)
	end
end

function emptyPowerState(power)
    return {
        power = power.key,
        active = false
    }
end

addEventHandler("onPlayerJoin", getRootElement(), function()
	outputServerLog("onPlayerJoin")
	powerStates[source] = {}
    resetPowerStatesForPlayer2(source)
end)
  --unbind on quit

addEventHandler("onPlayerQuit", getRootElement(), function()
	loopOverPowersForPlayer2(source, function(player, powerUp, powerUpState, powerConfig)
		endActivePowers2(player, powerUp, powerUpState)
	end)
    powerStates[source] = nil
end)

registerBindFunctions(function(player)
    bindKey(player, "C", "down", powerKeyDown)
    bindKey(player, "C", "up", powerKeyUp)
	bindKey(player, "mouse1", "down", powerKeyDown)
    bindKey(player, "mouse1", "up", powerKeyUp)
end, function(player)
    unbindKey(player, "C", "down", powerKeyDown)
    unbindKey(player, "C", "up", powerKeyUp)
	unbindKey(player, "mouse1", "down", powerKeyDown)
    unbindKey(player, "mouse1", "up", powerKeyUp)
end)