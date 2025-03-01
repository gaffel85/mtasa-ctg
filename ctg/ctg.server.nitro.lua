local boostCooldown
local boosterAdded = false
local nitroEndsTime

local nitroPowerUp2 = {
	cooldown = BOOST_COOLDOWN,
	duration = NITRO_DURATION,
	onEnable = function(player)
		bindKey(player, "lctrl", "down", usingBooster)
	end,
	onDisable = function(player)
		unbindKey(player, "lctrl", "down", usingBooster)
	end,
	onAcitavted = function(player, vehicle)
		addVehicleUpgrade(vehicle, 1009)
	end,
	onDeactivated = function(player, vehicle)
		removeVehicleUpgrade(vehicle, 1009)
	end	
}

function setBoostCooldownNitro(duration)
	local time = getRealTime()
	boostCooldown = time.timestamp + duration
end

function setNitroEndsTime(duration)
	local time = getRealTime()
	nitroEndsTime = time.timestamp + duration
end

function usingBoosterNitro()
	if (boosterAdded) then
		setNitroEndsTime(NITRO_DURATION)
		resetBoosterCountdown()
	end
end

function resetBoosterCountdownNitro()
	if (boosterAdded) then
		boosterAdded = false
		setBoostCooldown(BOOST_COOLDOWN)
	end
end

function boostCooldownLeftNitro() 
	local currentTime = getRealTime()
	return boostCooldown - currentTime.timestamp
end

function durationLeftNitro() 
	local currentTime = getRealTime()
	return nitroEndsTime - currentTime.timestamp
end

function tickCooldown()
	if ( boostCooldown == nil ) then
		return
	end

	local bombHolder = getBombHolder()
	local timeLeft = boostCooldownLeft()
	if (timeLeft >= 0 and boosterAdded == false and bombHolder) then
		triggerClientEvent("boosterCooldownTick", bombHolder, timeLeft, BOOST_COOLDOWN)
	end

	if ( timeLeft <= 0 and boosterAdded == false ) then
		local vehicle = getPedOccupiedVehicle (bombHolder)
		if (vehicle) then
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
		if (vehicle) then
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
	if ( oldBombHolder ) then
		unbindKey(oldBombHolder, "lctrl", "down", usingBooster)
	end

	setBoostCooldown(5)
end
-- addEventHandler("bombHolderChanged", root, onBombHolderChanged)