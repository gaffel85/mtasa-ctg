local nitroPowerUp = {
	key = "nitro",
	name = "Nitro",
	desc = "Nitro is a powerup that gives you a speed boost for a short period of time. It can be activated by pressing the left control key.",
	bindKey = "lctrl",
	resourceKey = "energy",
	burnRate = 15,
	minResourceAmount = 30,
	cooldown = function() return 0.2 end,
	duration = function() return getPowerConst().nitro.duration end,
	initCooldown = function() return getPowerConst().nitro.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().nitro.allowedGoldCarrier end,
	charges = function() return getPowerConst().nitro.charges end,
	rank = function() return getPowerConst().nitro.rank end,
	onEnable = function(player, vehicle)
		--outputChatBox("Nitro enabled "..getPlayerName(player))
		if not setVehicleNitroActivated(vehicle, false) then
			outputChatBox("Failed DEactivate nitro")
		end
		return true
	end,
	onDisable = function(player, vehicle)
		--outputChatBox("Nitro onDisabled"..getPlayerName(player))
		if not setVehicleNitroActivated(vehicle, false) then
			outputChatBox("Failed DEactivate nitro")
		end
		removeVehicleUpgrade(vehicle, 1009)
	end,
	onActivated = function(player, vehicle)
		--outputChatBox("Nitro activated"..getPlayerName(player))
		addVehicleUpgrade(vehicle, 1009)
		if not setVehicleNitroActivated(vehicle, true) then
			outputChatBox("Failed Activate nitro")
		end
	end,
	onDeactivated = function(player, vehicle)
		--outputChatBox("Nitro deactivated"..getPlayerName(player))
		if not setVehicleNitroActivated(vehicle, false) then
			outputChatBox("Failed DEactivate nitro")
		end
		removeVehicleUpgrade(vehicle, 1009)
	end	
}

addResourcePower(nitroPowerUp)