-- This file is the main controller for the resource-based power-up system.
-- It handles power-up state changes, activation, deactivation, and key bindings.

-- Enum for power-up states.
local stateEnum = {
	READY = 1,
	COOLDOWN = 2,
	IN_USE = 3,
	OUT_OF_CHARGES = 4,
	PAUSED = 5,
	WAITING = 6
}

-- A key for displaying a notification when a power-up is activated.
local NOTIFY_POWER_ACTIVATED_KEY = 8914555
-- Displays a notification to all players when a power-up is activated.
function notifyPowerActivated(player, powerUpName)
	displayMessageForAll(NOTIFY_POWER_ACTIVATED_KEY, getPlayerName(player).." activated "..powerUpName, player, "", 3000, 0.5, 0.3, 255, 100, 0, 255, 2 )
end

-- Resets the power-up states for all players when a delivery is made.
function resetPowerStatesForAllPlayers()
	for i, player in ipairs(getElementsByType("player")) do
		resetPowerStatesForPlayer(player)
	end
end

-- Resets the power-up states for a single player.
function resetPowerStatesForPlayer(player)
	local powerUps = getPowers()
	for j, powerUp in ipairs(powerUps) do
		if powerUp then
			resetPowerState(player, powerUp)
		else
			outputServerLog("PowerUp not found "..inspect(powerUp.key))
		end
	end
end

-- Handles the change of the gold carrier.
-- Pauses or unpauses power-ups for the old and new gold carriers.
function handlePowersForGoldCarrierChanged(newGoldCarrier, oldGoldCarrier)
	if oldGoldCarrier then
		loopOverPowersForPlayer(oldGoldCarrier, function(player, powerUp, powerUpState)
			if not powerUp.allowedGoldCarrier() then
				unpausePower(player, powerUp, powerUpState)
			end
		end)
	end

	if newGoldCarrier then
		loopOverPowersForPlayer(newGoldCarrier, function(player, powerUp, powerUpState)
			if not powerUp.allowedGoldCarrier() then
				if powerUpState.state == stateEnum.IN_USE then
					endUsePower(player, powerUp, powerUpState)
				else
					pausePower(player, powerUp, powerUpState)
				end
			end
		end)
	end
end

-- Returns the state enum.
function getStateEnum()
    return stateEnum
end

-- Ends all active power-ups for a player.
function endActivePowers(player, powerUp, powerUpState)
	if not powerUpState then
		return
	end

	if powerUpState.timer then
		killPowerTimer(powerUpState)
		powerUpState.timer = nil
	end

	if powerUpState.state == stateEnum.PAUSED then
		unpausePower(player, powerUp, powerUpState)
	end

	if powerUpState.state == stateEnum.IN_USE or powerUpState.state == stateEnum.READY then
		local vehicle = getPedOccupiedVehicle (player)
		if vehicle then
			powerUp.onDeactivated(player, vehicle)
		end
	end
end

-- Resets the state of a single power-up for a player.
function resetPowerState(player, powerUp)
    local powerUpState = PowerStateRepo:getPowerState(player, powerUp)
	
	if powerUpState then
		-- get old state and kill timer
		endActivePowers(player, powerUp, powerUpState)
	else
		powerUpState = PowerStateRepo:initPowerState(player, powerUp, stateEnum.READY)
	end
	tryEnablePower(powerUp, powerUpState, player)
	return powerUpState
end

-- Kills the timer associated with a power-up state.
function killPowerTimer(state)
	if state.timer then
		killTimer(state.timer)
		state.timer = nil
	end
end

-- Pauses a power-up for a player.
function pausePower(player, powerUp, powerUpState)
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

	setState(powerUp, player, stateEnum.PAUSED, "Paused while leading", powerUpState, nil)
	local vehicle = getPedOccupiedVehicle (player)
	if vehicle then
		powerUp.onDeactivated(player, vehicle)
	end
	killPowerTimer(powerUpState)
end

-- Unpauses a power-up for a player.
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
			setState(powerUp, player, stateEnum.OUT_OF_CHARGES, "Out of charges", powerUpState, nil)
		end
	end

	powerUpState.timeLeftOnPause = nil
	powerUpState.stateBeforePause = nil
end

-- Sets the end time for a power-up state.
function setEndsTime(duration, state)
	local time = getRealTime()
	local endsTime = time.timestamp + duration
	state.endTime = endsTime
end

-- Tries to enable a power-up for a player.
function tryEnablePower(powerUp, powerUpState, player)
	if getGoldCarrier() == player and not powerUp.allowedGoldCarrier() then
		pausePower(player, powerUp, powerUpState)
		return
	end

	local vehicle = getPedOccupiedVehicle (player)
	if not vehicle then
		setStateWithTimer(stateEnum.WAITING, 2, powerUpState, player, powerUp, "Waiting for vehicle")
		return
	end

	local wasEnabledOrWaitTime = powerUp.onEnable(player, vehicle)
	if (wasEnabledOrWaitTime) then
		local resource = getResource(powerUp.resourceKey)
		local resourceState = getResourceEnergyState(player, powerUp.resourceKey)
		if resource and resource.type == "time" and resourceState.amount <= 0 then
			setStateWithTimer(stateEnum.COOLDOWN, getCooldown(powerUp), powerUpState, player, powerUp, "Refilling")
		else
			setState(powerUp, player, stateEnum.READY, "Ready", powerUpState, nil)
			powerUpState.endTime = nil
		end
	else
		setStateWithTimer(stateEnum.WAITING, wasEnabledOrWaitTime.pollTime, powerUpState, player, powerUp, wasEnabledOrWaitTime.message)
	end
end

-- Tries to deactivate a power-up for a player.
function tryDeactivatePower(powerUp, powerUpState, player)
	local vehicle = getPedOccupiedVehicle (player)
	if vehicle then
		powerUp.onDeactivated(player, vehicle, powerUpState)
	end

	if powerUpState.charges and powerUpState.charges <= 0 then
		setState(powerUp, player, stateEnum.OUT_OF_CHARGES, "Out of charges", powerUpState, nil)
	else
		setStateWithTimer(stateEnum.COOLDOWN, getCooldown(powerUp), powerUpState, player, powerUp)
	end
end

-- Returns the cooldown duration for a power-up.
-- For time-based resources, it calculates the cooldown based on the resource's capacity and fill rate.
function getCooldown(powerUp)
	local resource = getResource(powerUp.resourceKey)
	if resource and resource.type == "time" then
		return resource.capacity / resource.fillRate
	end

	if powerUp.cooldown() > 0 then
		return powerUp.cooldown()
	end
	return 0
end

-- Resets the amount of a time-based resource for a player to its full capacity.
function resetIfResourceTypeIsTime(player, powerUp)
	local resource = getResource(powerUp.resourceKey)
	if resource and resource.type == "time" then
		setAmount(player, powerUp.resourceKey, resource.capacity)
	end
end

-- This function is called when a power-up timer is done.
-- It handles the state transitions for cooldown, in-use, and waiting states.
-- For time-based resources, it also resets the resource amount after the cooldown.
function timerDone(player, powerUpKey)
	local powerUp = findPowerWithKey(powerUpKey)
	local powerUpState = getPlayerState(player, powerUp)
	killPowerTimer(powerUpState)
	if powerUpState.state == stateEnum.COOLDOWN then
		resetIfResourceTypeIsTime(player, powerUp)
		tryEnablePower(powerUp, powerUpState, player)
	elseif powerUpState.state == stateEnum.IN_USE then
		endUsePower(player, powerUp, powerUpState)
	elseif powerUpState.state == stateEnum.WAITING then
		tryEnablePower(powerUp, powerUpState, player)
	end
end

-- Calculates the time for a full resource burn based on the resource amount and the power-up's burn rate.
function timeForFullResourceBurn(player, powerUp)
    local resourceState = getResourceEnergyState(player, powerUp.resourceKey)
    local maxSeconds = resourceState.amount / powerUp.burnRate
    return maxSeconds
end

-- Sets a timer for a power-up state.
function setStateWithTimer(stateType, duration, state, player, powerUp, message)
	setEndsTime(duration, state)
	setState(powerUp, player, stateType, message, state)
	local seconds = timeLeft(state)

	if seconds <= 0 then
		timerDone(player, powerUp.key)
		return
	end

	state.timer = setTimer(function()
		timerDone(player, powerUp.key)
	end, seconds * 1000, 1)
end

-- Returns the time left for a power-up state.
function timeLeft(powerUpState)
	local currentTime = getRealTime()
	if not powerUpState.endTime then
		return 0
	end
	return powerUpState.endTime - currentTime.timestamp
end

-- Returns the state of a power-up for a player.
function getPlayerState(player, powerUp)
	local powerUpState = PowerStateRepo:getPowerState(player, powerUp)
	if (not powerUpState) then
		powerUpState = resetPowerState(player, powerUp)
	end
	return powerUpState
end

-- Sets the state of a power-up for a player and notifies the client.
function setState(powerUp, player, stateType, stateMessage, state)
	if not state then
		state = getPlayerState(player, powerUp)
	end

	local oldState = state.state
	state.state = stateType
	state.stateMessage = stateMessage
	local totalCharges = 0
	if powerUp.charges() and powerUp.charges() > 0 then
		totalCharges = powerUp.charges()
	end

	local timeLeft = timeLeft(state)
	triggerClientEvent(player, "powerStateChangedClient", player, stateType, oldState, powerUp.key, stateMessage, nil, state.charges, totalCharges, timeLeft)
end

-- Ends the use of a power-up.
function endUsePower(player, powerUp, powerUpState)
	triggerClientEvent(player, "resourceNotInUseFromServer", getRootElement(), powerUp.resourceKey, 0)
	if powerUpState.state ~= stateEnum.IN_USE then
		return
	end
	tryDeactivatePower(powerUp, powerUpState, player)
end

-- Activates a power-up for a player.
function usePowerUp(player, key, keyState, powerUp)
	if getGoldCarrier() == player and not powerUp.allowedGoldCarrier() then
		outputChatBox("Power not allowed while carrying gold!", player)
		return
	end

	local state = getPlayerState(player, powerUp)
	local resourceState = getResourceEnergyState(player, powerUp.resourceKey)
	if resourceState.amount < powerUp.minResourceAmount then
		outputChatBox("Not enough "..powerUp.resourceKey.." to use "..powerUp.name..", requires "..powerUp.minResourceAmount.." "..powerUp.resourceKey.." ("..resourceState.amount.." available)", player)
		return
	end
	if not (state.state == stateEnum.READY) then
		outputChatBox("Power not ready yet: "..inspect(powerUp.name), player)
		return
	end

    local calculateMaxDuration = timeForFullResourceBurn(player, powerUp)

	setStateWithTimer(stateEnum.IN_USE, calculateMaxDuration, state, player, powerUp, "In use")
	triggerClientEvent(player, "resourceInUseFromServer", getRootElement(), powerUp.resourceKey, powerUp.burnRate, powerUp.minBurn)
	if state.charges and state.charges > 0 then
		state.charges = state.charges - 1
	end

	local vehicle = getPedOccupiedVehicle(player)
	if (vehicle) then
		local realPowerUp = findPowerWithKey(powerUp.key)
		if (realPowerUp) then
			realPowerUp.onActivated(player, vehicle, state)
		end
	else
		-- outputChatBox("vehicle is nil")
	end

	if powerUp.minBurn then
	addAmount(player, powerUp.resourceKey, -1 * powerUp.minBurn)
	end
end

-- Loops over all active power-ups for a player.
function loopOverPowersForPlayer(player, callback)
	local powerUps = getPowers()
	for j, powerUp in ipairs(powerUps) do
		if powerUp == nil then
			outputServerLog("powerUp is nil")
			break
		end
		local powerUpState = getPlayerState(player, powerUp)
		if not powerUpState then
			outputServerLog("powerUpState is nil "..inspect(powerUp.key))
			break
		end
		callback(player, powerUp, powerUpState)
	end
end

-- This event is triggered when the client-side energy amount changes.
addEventHandler("energyAmountChangedFromClient", resourceRoot, function(key, amount, secondsUntilEnd, isBurning, burnRate, fillRate)
	if isBurning then
		local player = client
		local powerUps = findPowersWithResource(key)
		for i, powerUp in ipairs(powerUps) do
			local powerUpState = getPlayerState(player, powerUp)
			if not powerUpState then
				outputServerLog("powerUpState is nil "..inspect(powerUp.key))
				break
			end
			if powerUpState.state == stateEnum.IN_USE then
				killPowerTimer(powerUpState)
				setStateWithTimer(stateEnum.IN_USE, secondsUntilEnd, powerUpState, player, powerUp)
			end
		end
	end
end)

function getPowerKeyBindings()
    return {
        { key = "nitro", bindKey = "lctrl", toggle = true },
        { key = "nitro", bindKey = "mouse1", toggle = false },
        { key = "jump", bindKey = "mouse2", toggle = false },
        { key = "jump", bindKey = "lshift", toggle = false },
        { key = "canon", bindKey = "C", toggle = false },
        { key = "superCar", bindKey = "1", toggle = true },
        { key = "offroad", bindKey = "2", toggle = true },
        { key = "airplane", bindKey = "3", toggle = true },
    }
end

-- Returns the power-up, power-up state, and power-up config for a given button.
function powerForButton(player, button)
	local powerConfig = getPowerKeyBindings()
	local powerForBoundKey = nil
	for i, powerUpConfig in ipairs(powerConfig) do
		if (string.lower(powerUpConfig.bindKey) == string.lower(button)) then
			powerForBoundKey = powerUpConfig
			break
		end
	end

	local powerUpState = nil
	local powerUp = nil
	if (powerForBoundKey) then
		powerUp = findPowerWithKey(powerForBoundKey.key)
		if (powerUp) then
			powerUpState = getPlayerState(player, powerUp)
		end
	else 
-- outputChatBox("No power bound for button: "..button)
	end
	return powerUp, powerUpState, powerForBoundKey
end

-- This function is called when a power-up key is pressed down.
function powerKeyDown(player, button, keyState)
	local power, powerState, powerConfig = powerForButton(player, button)
	if not power or not powerState then
		outputServerLog("No power found for button: "..button)
		return
	end

	if powerConfig.toggle then
	else
		usePowerUp(player, button, buttonState, power)
	end
end

-- This function is called when a power-up key is released.
function powerKeyUp(player, button, keyState)
    local power, powerState, powerConfig = powerForButton(player, button)
	if not power or not powerState then
		outputServerLog("No power found for button: "..button)
		return
	end
	
	if powerConfig.toggle then
		if powerState.state == stateEnum.IN_USE then
			endUsePower(player, power, powerState)
		else
			usePowerUp(player, button, buttonState, power)
		end
	else
		endUsePower(player, power, powerState)
	end
end

-- Resets all power-ups and resources for a player.
function forceResetPowers(player)
    outputChatBox("Resetting powers...", player)
    loopOverPowersForPlayer(player, function(p, powerUp, powerUpState)
		endActivePowers(p, powerUp, powerUpState)
	end)
    PowerStateRepo:removeStateForPlayer(player)
	PowerStateRepo:clearStateForPlayer(player)
	initAllResourceStatesForPlayer(player)
	setAmount(player, "vehicleTime", 0)
    resetPowerStatesForPlayer(player)

    -- Manually start cooldown for a vehicleTime power to trigger refill
    local powerToPutOnCooldown = nil
    local powerConfig = getPowerKeyBindings()
    for j, powerUpConfig in ipairs(powerConfig) do
        local powerUp = findPowerWithKey(powerUpConfig.key)
        if powerUp and powerUp.resourceKey == "vehicleTime" then
            powerToPutOnCooldown = powerUp
            break
        end
    end

    if powerToPutOnCooldown then
        local powerUpState = getPlayerState(player, powerToPutOnCooldown)
        setStateWithTimer(stateEnum.COOLDOWN, getCooldown(powerToPutOnCooldown), powerUpState, player, powerToPutOnCooldown, "Resetting")
    end
	outputServerLog("Powers reset for player "..inspect(getPlayerName(player)))
	if (getGoldCarrier() == player) then
		-- Re-apply gold carrier restrictions after reset
		loopOverPowersForPlayer(player, function(p, powerUp, powerUpState)
			if not powerUp.allowedGoldCarrier() then
				pausePower(p, powerUp, powerUpState)
			end
		end)
	end
end

-- Returns an empty power state.
function emptyPowerState(power)
    return {
        power = power.key,
        active = false
    }
end

-- Event handler for player join.
addEventHandler("onPlayerJoin", getRootElement(), function()
	outputServerLog("onPlayerJoin")
	PowerStateRepo:clearStateForPlayer(source)
    resetPowerStatesForPlayer(source)
end)

-- Event handler for player quit.
addEventHandler("onPlayerQuit", getRootElement(), function()
	loopOverPowersForPlayer(source, function(player, powerUp, powerUpState)
		endActivePowers(player, powerUp, powerUpState)
	end)
    PowerStateRepo:removeStateForPlayer(source)
end)

-- Event handler for resource start.
addEventHandler("onResourceStart", resourceRoot, function()
    resetPowerStatesForAllPlayers()
end)

-- Registers the keybind functions.
registerBindFunctions(function(player)
	bindKey(player, "mouse1", "down", powerKeyDown)
    bindKey(player, "mouse1", "up", powerKeyUp)
	bindKey(player, "mouse2", "down", powerKeyDown)
    bindKey(player, "mouse2", "up", powerKeyUp)
	bindKey(player, "C", "down", powerKeyDown)
    bindKey(player, "C", "up", powerKeyUp)
	bindKey(player, "lctrl", "down", powerKeyDown)
    bindKey(player, "lctrl", "up", powerKeyUp)
	bindKey(player, "lshift", "down", powerKeyDown)
    bindKey(player, "lshift", "up", powerKeyUp)
	bindKey(player, "1", "down", powerKeyDown)
	bindKey(player, "1", "up", powerKeyUp)
	bindKey(player, "2", "down", powerKeyDown)
	bindKey(player, "2", "up", powerKeyUp)
	bindKey(player, "3", "down", powerKeyDown)
	bindKey(player, "3", "up", powerKeyUp)
    bindKey(player, "g", "down", forceResetPowers)
end, function(player)
	unbindKey(player, "mouse1", "down", powerKeyDown)
    unbindKey(player, "mouse1", "up", powerKeyUp)
	unbindKey(player, "mouse2", "down", powerKeyDown)
    unbindKey(player, "mouse2", "up", powerKeyUp)
	unbindKey(player, "C", "down", powerKeyDown)
    unbindKey(player, "C", "up", powerKeyUp)
	unbindKey(player, "lctrl", "down", powerKeyDown)
    unbindKey(player, "lctrl", "up", powerKeyUp)
	unbindKey(player, "lshift", "down", powerKeyDown)
    unbindKey(player, "lshift", "up", powerKeyUp)
	unbindKey(player, "1", "down", powerKeyDown)
	unbindKey(player, "1", "up", powerKeyUp)
	unbindKey(player, "2", "down", powerKeyDown)
	unbindKey(player, "2", "up", powerKeyUp)
	unbindKey(player, "3", "down", powerKeyDown)
	unbindKey(player, "3", "up", powerKeyUp)
    unbindKey(player, "g", "down", forceResetPowers)
end)