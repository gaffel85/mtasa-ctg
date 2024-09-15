local nitroPowerUp = {
	key = "nitro",
	name = "Nitro",
	bindKey = "lctrl",
	cooldown = BOOST_COOLDOWN,
	duration = NITRO_DURATION,
	onEnable = function(player)
		addVehicleUpgrade(vehicle, 1009)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle)
		outputChatBox("Nitro activated", player)
	end,
	onDeactivated = function(player, vehicle)
		removeVehicleUpgrade(vehicle, 1009)
	end	
}

local teleportPowerUp = {
	key = "teleport",
	name = "Catch up",
	bindKey = "x",
	cooldown = TELEPORT_COOLDOWN,
	duration = 0,
	onEnable = function(player)
		return isFarEnoughFromLeader(player)
	end,
	onDisable = function(player)
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
	cooldownEnd = nil
}

local powerUpStates = {}
local powerUps = {}

function addPowerUp(powerUp)
	table.insert(powerUps, powerUp)
	powerUpStates[powerUp.key] = {}
end

function setBoostCooldown(powerUp, state)
	local time = getRealTime()
	local boostCooldown = time.timestamp + powerUp.cooldown
	state.cooldownEnd = boostCooldown
end

function setPowerUpEndsTime(powerUp)
	local time = getRealTime()
	local endsTime = time.timestamp + powerUp.duration
	powerUp.durationEnd = endsTime
end

function usingBooster(powerUp)
	if (powerUp.activated) then
		setPowerUpEndsTime(powerUp)
		resetBoosterCountdown()
	end
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
		states[player] = powerUpState
	end
	return powerUpState
end

function usePowerUp(player, key, keyState, powerUp)
	local state = getPlayerState(player, powerUp)
	state.activated = true
	setPowerUpEndsTime(powerUp, state)
	powerUp.onActivated(player, getPedOccupiedVehicle(player), state)
	unbindKey(player, key, keyState, usePowerUp, powerUp)
end

function tickPowerUps()
	for i, player in ipairs(getElementsByType("player")) do
		for j, powerUp in ipairs(powerUps) do
			local powerUpState = getPlayerState(player, powerUp)

			if (player == getGoldCarrier()) then
				if (powerUpState.enabled) then
					unbindKey(player, powerUp.bindKey, "down", usePowerUp, powerUp)
					powerUp.onDisabled(player, getPedOccupiedVehicle(player), powerUpState)
					powerUpState.enabled = false
				end
				if (powerUpState.activated) then
					powerUp.onDeactivated(player, getPedOccupiedVehicle(player), powerUpState)
					powerUpState.activated = false
					powerUpState.enabled = false
				end
			else
				if (powerUpState.actived) then
					local timeLeft = durationLeft(powerUpState)
					if (timeLeft >= 0) then
						triggerClientEvent(player, "boosterDurationTick", timeLeft, powerUp.duration, j, powerUp.name, powerUp.bindKey, true)
					end

					if (timeLeft <= 0) then
						local vehicle = getPedOccupiedVehicle (player)
						if (vehicle ~= nil) then
							powerUp.onDeactivated(player, vehicle, powerUpState)
							powerUpState.activated = false
							powerUpState.enabled = false
							setBoostCooldown(powerUp, powerUpState)
						end
					end
				elseif (powerUpState.enabled == false) then
					local timeLeft = boostCooldownLeft(powerUpState)
					if (timeLeft >= 0) then
						triggerClientEvent(player, "boosterCooldownTick", timeLeft, powerUp.cooldown, j, powerUp.name, powerUp.bindKey, true)
					end

					if (timeLeft <= 0) then
						local vehicle = getPedOccupiedVehicle (player)
						if (vehicle ~= nil) then
							local wasEnabled = powerUp.onEnable(player, vehicle)
							if (wasEnabled) then
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

function tickCooldown()
	for i, powerUp in ipairs(powerUps) do
		if (powerUp.enabled == false) then
			local timeLeft = boostCooldownLeft(powerUp)
			if (timeLeft >= 0) then
				triggerClientEvent("boosterCooldownTick", bombHolder, timeLeft, powerUp.cooldown, i, powerUp.name)
			end

			if (timeLeft <= 0) then
				local vehicle = getPedOccupiedVehicle (bombHolder)
				if (vehicle ~= nil) then
					powerUp.onEnabled(bombHolder, vehicle)
					powerUp.enabled = true
					showBooserAdded(bombHolder)
				end
			end
		end
	end
	if ( boostCooldown == nil ) then
		return
	end

	local bombHolder = getBombHolder()
	local timeLeft = boostCooldownLeft()
	if (timeLeft >= 0 and boosterAdded == false and bombHolder ~= nil) then
		triggerClientEvent("boosterCooldownTick", bombHolder, timeLeft, BOOST_COOLDOWN)
	end

	if ( timeLeft <= 0 and boosterAdded == false ) then
		local vehicle = getPedOccupiedVehicle (bombHolder)
		if (vehicle ~= nil) then
			addVehicleUpgrade(vehicle, 1009)
			boosterAdded = true
			showBooserAdded(bombHolder)
		end
	end
end

function tickDuration()
	if (nitroEndsTime == nil) then
		return
	end

	local bombHolder = getBombHolder()
	local timeLeft = durationLeft()
	if ( timeLeft <= 0) then
		local vehicle = getPedOccupiedVehicle (bombHolder)
		if (vehicle ~= nil) then
			removeVehicleUpgrade(vehicle, 1009)
			nitroEndsTime = nil
		end
	end
end

function tickNitro()
	if (getGameState() ~= GAME_STATE_ACTIVE_GAME) then
		return
	end

	tickCooldown()
	tickDuration()
end
-- setTimer(tickNitro, 1000, 0)

function onBombHolderChanged(oldBombHolder)
	local bombHolder = source
	boosterAdded = false
	bindKey(bombHolder, "lctrl", "down", usingBooster)
	if ( oldBombHolder ~= nil ) then
		unbindKey(oldBombHolder, "lctrl", "down", usingBooster)
	end

	setBoostCooldown(5)
end
-- addEventHandler("bombHolderChanged", root, onBombHolderChanged)