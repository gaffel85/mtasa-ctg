local nitroPowerUp = {
	key = "nitro",
	name = "Nitro",
	bindKey = "lctrl",
	cooldown = BOOST_COOLDOWN,
	duration = NITRO_DURATION,
	initCooldown = 5,
	onEnable = function(player, vehicle)
		outputChatBox("Nitro enabled "..getPlayerName(player))
		addVehicleUpgrade(vehicle, 1009)
		return true
	end,
	onDisable = function(player, vechilce)
		outputChatBox("Nitro onDisabled"..getPlayerName(player))
	end,
	onActivated = function(player, vehicle)
		outputChatBox("Nitro activated"..getPlayerName(player))
	end,
	onDeactivated = function(player, vehicle)
		outputChatBox("Nitro deactivated"..getPlayerName(player))
		removeVehicleUpgrade(vehicle, 1009)
	end	
}

local teleportPowerUp = {
	key = "teleport",
	name = "Catch up",
	bindKey = "x",
	cooldown = TELEPORT_COOLDOWN,
	duration = 0,
	initCooldown = 5,
	onEnable = function(player, vehicle)
		return isFarEnoughFromLeader(player)
	end,
	onDisable = function(player, vehicle)
	end,
	onActivated = function(player, vehicle)
		askForTeleport(player)
	end,
	onDeactivated = function(player, vehicle)
	end	
}

local superCarPowerUp = {
	key = "superCar",
	name = "Super car",
	bindKey = "c",
	cooldown = 20,
	duration = 20,
	initCooldown = 5,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		state.oldVehicleModel = getElementModel(vehicle)
		setElementModel(theVehicle, SUPER_CAR_MODEL)
	end,
	onDeactivated = function(player, vehicle, state)
		setElementModel(vehicle, state.oldVehicleModel)
	end	
}

local initialState = {
	enabled = false,
	activated = false,
	durationEnd = nil,
	cooldownEnd = 0
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
	local powerUpState = states[player]
	if (powerUpState == nil) then
		powerUpState = initialState
		setBoostCooldown(powerUp.initCooldown, powerUpState)
		states[player] = powerUpState
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

function usePowerUp(player, key, keyState, powerUp)
	outputServerLog("usePowerUp "..getPlayerName(player).." "..powerUp.name.." "..key.." "..keyState)
	outputChatBox("usePowerUp "..getPlayerName(player).." "..powerUp.name.." "..key.." "..keyState)
	local state = getPlayerState(player, powerUp)
	state.activated = true
	outputChatBox("state: "..tostring(state.activated))
	outputServerLog("state: "..inspect(state))
	setPowerUpEndsTime(powerUp, state)
	local vehicle = getPedOccupiedVehicle(player)
	if (vehicle ~= nil) then
		local realPowerUp = findPowerUpWithKey(powerUp.key)
		if (realPowerUp ~= nil) then
			realPowerUp.onActivated(player, vehicle, state)
		end
	else
		outputChatBox("vehicle is nil")
	end
	
	unbindKey(player, key, keyState, usePowerUp, powerUp)
end

function tickPowerUps()
	for i, player in ipairs(getElementsByType("player")) do
		for j, powerUp in ipairs(powerUps) do
			local powerUpState = getPlayerState(player, powerUp)

			if (player == getGoldCarrier()) then
				outputChatBox("player is gold carrier")
				if (powerUpState.enabled) then
					unbindKey(player, powerUp.bindKey, "down", usePowerUp, powerUp)
					powerUp.onDisable(player, getPedOccupiedVehicle(player), powerUpState)
					powerUpState.enabled = false
				end
				if (powerUpState.activated) then
					powerUp.onDeactivated(player, getPedOccupiedVehicle(player), powerUpState)
					powerUpState.activated = false
					powerUpState.enabled = false
				end
			else
				if (powerUpState.actived == true) then
					outputChatBox("powerUpState.actived")
					local timeLeft = durationLeft(powerUpState)
					outputChatBox("timeLeft "..timeLeft)
					if (timeLeft >= 0) then
						outputChatBox("triggerClientEvent "..timeLeft.." "..powerUp.duration.." "..j.." "..powerUp.name.." "..powerUp.bindKey.." true")
						triggerClientEvent(player, "boosterDurationTick", player, timeLeft, powerUp.duration, j, powerUp.name, powerUp.bindKey, true)
					end

					if (timeLeft <= 0) then
						outputChatBox("timeLeft <= 0")
						local vehicle = getPedOccupiedVehicle (player)
						if (vehicle ~= nil) then
							outputChatBox("deactivate powerUp")
							powerUp.onDeactivated(player, vehicle, powerUpState)
							powerUpState.activated = false
							powerUpState.enabled = false
							setBoostCooldown(powerUp.coolDown, powerUpState)
							outputChatBox("cooldown reset to "..powerUpState.cooldownEnd)
						end
					end
				elseif (powerUpState.enabled == false) then
					outputChatBox("powerUpState.enabled == false")
					local timeLeft = boostCooldownLeft(powerUpState)
					outputChatBox("timeLeft "..timeLeft)
					if (timeLeft >= 0) then
						outputChatBox("triggerClientEvent "..timeLeft.." "..powerUp.cooldown.." "..j.." "..powerUp.name.." "..powerUp.bindKey.." true")
						triggerClientEvent(player, "boosterCooldownTick", player, timeLeft, powerUp.cooldown, j, powerUp.name, powerUp.bindKey, true)
					end

					if (timeLeft <= 0) then
						outputChatBox("timeLeft <= 0")
						local vehicle = getPedOccupiedVehicle (player)
						if (vehicle ~= nil) then
							local wasEnabled = powerUp.onEnable(player, vehicle)
							outputChatBox("wasEnabled "..tostring(wasEnabled))
							if (wasEnabled) then
								outputChatBox("bindKey "..powerUp.bindKey)
								bindKey(player, powerUp.bindKey, "down", usePowerUp, powerUp)
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

addPowerUp(nitroPowerUp)