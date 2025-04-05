--function addPowerUp(powerUp)
	--outputServerLog("Adding powerup "..inspect(powerUp))
	--table.insert(powerUps, powerUp)
	--powerUpStates[powerUp.key] = {}
--end

function getPlayerPowerConfig2(player)
    return {
        active = {
            { key = "nitro", bindKey = "lctrl", toggle = true },
			{ key = "nitro", bindKey = "mouse1", toggle = false },
			{ key = "jump", bindKey = "mouse2", toggle = false },
			{ key = "jump", bindKey = "lshift", toggle = false },
			{ key = "canon", bindKey = "C", toggle = false },
			{ key = "supercar", bindKey = "1", toggle = true },
			{ key = "offroad", bindKey = "2", toggle = true },
			--{ key = "airplane", bindKey = "3", toggle = true },
        }
    }
end

function resetPowerStatesOnDeliverdResourceBased()
	resetPowerStatesOnDeliverd()
	for i, player in ipairs(getElementsByType("player")) do
		setCompletedRank(player, getUsedRank(player))
		resetPowerStatesForPlayer2(player)
	end
end

function resetPowerStatesForPlayer2(player)
	local powerConfig = getPlayerPowerConfig2(player)
	for j, powerUpConfig in ipairs(powerConfig.active) do
		local powerUp = findPowerWithKey(powerUpConfig.key)
		--outputServerLog("------ resetPowerStatesForPlayer "..inspect(player).." "..inspect(powerUp).." "..inspect(powerUpConfig))
		if powerUp then
			resetPowerState2(player, powerUp)
		else
			outputServerLog("PowerUp not found "..inspect(powerUpConfig.key))
		end
	end
end

function handlePowersForGoldCarrierChangedResourceBased(newGoldCarrier, oldGoldCarrier)
	handlePowersForGoldCarrierChanged(newGoldCarrier, oldGoldCarrier)
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
	if not powerUpState then
		return
	end

	if powerUpState.timer then
		killPowerTimer2(powerUpState)
		powerUpState.timer = nil
	end

	if powerUpState.state == stateEnum.PAUSED then
		unpausePower2(player, powerUp, powerUpState)
	end

	if powerUpState.state == stateEnum.IN_USE or powerUpState.state == stateEnum.READY then
		local vehicle = getPedOccupiedVehicle (player)
		if vehicle then
			powerUp.onDeactivated(player, vehicle)
		end
	end
end

function resetPowerState2(player, powerUp)
    local powerUpState = PowerStateRepo:getPowerState(player, powerUp)
	
	if powerUpState then
		-- get old state and kill timer
		endActivePowers2(player, powerUp, powerUpState)
	else
		powerUpState = PowerStateRepo:initPowerState(player, powerUp, stateEnum.READY)
	end
	--if powerUp.initCooldown() > 0 then
-- outputServerLog("initCooldown "..inspect(powerUp.initCooldown()))
		--setStateWithTimer2(stateEnum.COOLDOWN, powerUp.initCooldown(), powerUpState, player, powerUp)
	--else
-- outputServerLog("initCooldown 0")
	-- setState2(powerUp, player, stateEnum.READY, "Ready", powerUpState, nil)
	tryEnablePower2(powerUp, powerUpState, player)
	--end
	-- PowerStateRepo:setState(player, powerUp, powerUpState)
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
		--outputServerLog("1")
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
	--outputServerLog("3")
	local vehicle = getPedOccupiedVehicle (player)
	if vehicle then
		powerUp.onDeactivated(player, vehicle, powerUpState)
	end

	--outputServerLog("4")
	if powerUpState.charges and powerUpState.charges <= 0 then
		setState2(powerUp, player, stateEnum.OUT_OF_CHARGES, "Out of charges", state, nil)
	else
		--outputServerLog("5")
        --setState2(powerUp, player, stateEnum.READY, "Ready", powerUpState, nil)
		setStateWithTimer2(stateEnum.COOLDOWN, getCooldown(powerUp), powerUpState, player, powerUp)
	end
end

local function getCooldown(powerUp)
	local resource = getResource(powerUp.resourceKey)
	if resource and resource.type == "time" then
		return resource.capacity / resource.fillRate
	end

	if powerUp.cooldown() > 0 then
		return powerUp.cooldown()
	end
	return 0
end

function timerDone2(player, powerUpKey)
	local powerUp = findPowerWithKey(powerUpKey)
	-- outputServerLog("timerDone "..inspect(getPlayerName(player)))
	local powerUpState = getPlayerState2(player, powerUp)
	killPowerTimer2(powerUpState)
	--outputServerLog("timerDone2 "..inspect(powerUpState.state))
	if powerUpState.state == stateEnum.COOLDOWN then
		tryEnablePower2(powerUp, powerUpState, player)
	elseif powerUpState.state == stateEnum.IN_USE then
		endUsePower(player, powerUp, powerUpState)
	elseif powerUpState.state == stateEnum.WAITING then
		--outputServerLog("tryEnablePower2 after waiting")
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

	--outputServerLog("setStateWithTimer2 "..inspect(seconds))
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
	local powerUpState = PowerStateRepo:getPowerState(player, powerUp)
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

	local timeLeft = timeLeft2(state)
	--if powerUp.shareState then
		--outputServerLog("setState "..inspect(powerUp.key).." "..inspect(state.state).." "..inspect(state.stateMessage))
		--timeLeft = timeForFullResourceBurn(player, powerUp)
	--end

	triggerClientEvent(player, "powerupStateChangedClient", player, stateType, oldState, powerUp.name, stateMessage, config.bindKey, state.charges, totalCharges, timeLeft)
end

local function stateFromSharedResource(player, powerUp)

end

function endUsePower(player, powerUp, powerUpState)
	--outputServerLog("endUsePower "..inspect(getPlayerName(player)).." "..inspect(powerUp.key).." "..inspect(powerUpState.state))
	triggerClientEvent(player, "resourceNotInUseFromServer", getRootElement(), powerUp.resourceKey, 0)
	if powerUpState.state ~= stateEnum.IN_USE then
		return
	end
	-- resetResouceAmount(player, powerUp.resourceKey)
	tryDeactivatePower2(powerUp, powerUpState, player)
	--tryEnablePower2(powerUp, powerUpState, player)
end

function usePowerUp2(player, key, keyState, powerUp)
	--outputServerLog("usePowerUp "..getPlayerName(player).." "..powerUp.name.." "..key.." "..keyState)
	--outputChatBox("usePowerUp "..getPlayerName(player).." "..inspect(powerUp))
	
	local state = getPlayerState2(player, powerUp)
	--outputServerLog("usePowerUp "..inspect(getPlayerName(player)).." "..inspect(powerUp.resourceKey))
	local resourceState = getResourceState(player, powerUp.resourceKey)
	--outputServerLog("Resource "..inspect(powerUp.resourceKey).." "..inspect(resourceState.amount))
	if resourceState.amount < powerUp.minResourceAmount then
		outputChatBox("Not enough "..powerUp.resourceKey.." to use "..powerUp.name..", requires "..powerUp.minResourceAmount.." "..powerUp.resourceKey.." ("..resourceState.amount.." available)")
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
	triggerClientEvent(player, "resourceInUseFromServer", getRootElement(), powerUp.resourceKey, powerUp.burnRate, powerUp.minBurn)
	if state.charges and state.charges > 0 then
		state.charges = state.charges - 1
	end

	-- outputChatBox("state: "..tostring(state.activated))
	--outputServerLog("state: "..inspect(state))
	local vehicle = getPedOccupiedVehicle(player)
	if (vehicle) then
		local realPowerUp = findPowerWithKey(powerUp.key)
		--outputServerLog("realPowerUp: "..tostring(realPowerUp.name))
		if (realPowerUp) then
			--outputServerLog("activating: "..tostring(realPowerUp.name))
			realPowerUp.onActivated(player, vehicle, state)
		end
	else
		-- outputChatBox("vehicle is nil")
	end

	setAmount(player, powerUp.resourceKey, powerUp.minBurn)
	
	--unbindKey(player, key, keyState, usePowerUp, powerUp)
end

function loopOverPowersForPlayer2(player, callback)
	local powerConfig = getPlayerPowerConfig2(player)
	for j, powerUpConfig in ipairs(powerConfig.active) do
		local powerUp = findPowerWithKey(powerUpConfig.key)
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
	if isBurning then
		--outputServerLog("energy from client "..inspect(key).." "..inspect(amount).." "..inspect(secondsUntilEnd).." "..inspect(isBurning).." "..inspect(burnRate).." "..inspect(fillRate))
		local player = client
		local powerUps = findPowersWithResource(key)
		for i, powerUp in ipairs(powerUps) do
			--outputServerLog("energy from client "..inspect(powerUp.key).." "..inspect(player))
			local powerUpState = getPlayerState2(player, powerUp)
			if not powerUpState then
				outputServerLog("powerUpState is nil "..inspect(powerUp.key))
				break
			end
			--outputServerLog("energy from client "..inspect(powerUp.key).." "..inspect(player))
			if powerUpState.state == stateEnum.IN_USE then
				killPowerTimer2(powerUpState)
				setStateWithTimer2(stateEnum.IN_USE, secondsUntilEnd, powerUpState, player, powerUp)
			end
		end
	end
end)

--addEvent("loadPowerUpsServer", true)
--addEventHandler("loadPowerUpsServer", root, function()
--	local data = getPowerUpsData2()
--	--triggerClientEvent("onPowerupsLoadedClient", getRootElement(), data)
--	triggerClientEvent(client, "onPowerupsLoadedClient", this, data)
--	--triggerClientEvent(source, "onPowerupsLoadedClient", this, data)
--end)

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
		powerUp = findPowerWithKey(powerForBoundKey.key)
		if (powerUp) then
			--outputServerLog("powerButtonPressed "..inspect(powerUp.key).." "..inspect(player))
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
		powerUp = findPowerWithKey(powerForBoundKey.key)
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
	--outputServerLog("powerKeyDown: "..button)
	local power, powerState, powerConfig = powerForButton(player, button)
	if not power or not powerState then
		outputServerLog("No power found for button: "..button)
		return
	end

	-- outputServerLog("powerKeyDown Is toggle: "..inspect(powerConfig))
	if powerConfig.toggle then
		--outputServerLog("Is toggle, doing nothing")	
	else
		--outputServerLog("Is not toggle, starting power")
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
			--outputServerLog("Is in use, ending power")
			endUsePower(player, power, powerState)
		else
			--outputServerLog("Is not in use, starting power")
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
	PowerStateRepo:clearStateForPlayer(source)
    resetPowerStatesForPlayer2(source)
end)
  --unbind on quit

addEventHandler("onPlayerQuit", getRootElement(), function()
	loopOverPowersForPlayer2(source, function(player, powerUp, powerUpState, powerConfig)
		endActivePowers2(player, powerUp, powerUpState)
	end)
    PowerStateRepo:removeStateForPlayer(source)
end)

addEventHandler("onResourceStart", resourceRoot, function()
	--outputServerLog("onResourceStart claring states")
    resetPowerStatesOnDeliverdResourceBased()
end)

registerBindFunctions(function(player)
    --bindKey(player, "C", "down", powerKeyDown)
    --bindKey(player, "C", "up", powerKeyUp)
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
end, function(player)
    --unbindKey(player, "C", "down", powerKeyDown)
    --unbindKey(player, "C", "up", powerKeyUp)
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
end)