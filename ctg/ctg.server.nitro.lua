local boostCooldown
local boosterAdded = false
local nitroEndsTime

function setBoostCooldown(duration)
	local time = getRealTime()
	boostCooldown = time.timestamp + duration
end

function setNitroEndsTime(duration)
	local time = getRealTime()
	nitroEndsTime = time.timestamp + duration
end

function usingBooster()
	if (boosterAdded) then
		setNitroEndsTime(NITRO_DURATION)
		resetBoosterCountdown()
	end
end

function resetBoosterCountdown()
	if (boosterAdded) then
		boosterAdded = false
		setBoostCooldown(BOOST_COOLDOWN)
	end
end

function boostCooldownLeft() 
	local currentTime = getRealTime()
	return boostCooldown - currentTime.timestamp
end

function durationLeft() 
	local currentTime = getRealTime()
	return nitroEndsTime - currentTime.timestamp
end

function tickCooldown()
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
setTimer(tickNitro, 1000, 0)

function onBombHolderChanged(oldBombHolder)
	local bombHolder = source
	boosterAdded = false
	bindKey(bombHolder, "lctrl", "down", usingBooster)
	if ( oldBombHolder ~= nil ) then
		unbindKey(oldBombHolder, "lctrl", "down", usingBooster)
	end

	setBoostCooldown(5)
end
addEventHandler("bombHolderChanged", root, onBombHolderChanged)