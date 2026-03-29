local waterLevelPowerUp = {
	key = "waterLevel",
	name = "Flood",
    desc = "Makes the sea level rise to 2m below you. Vehicles in the water will not be able to move until the water level is back to normal.",
    iconPath = "img/flood.png",
	cooldown = function() return getPowerConst().waterLevel.cooldown end,
	duration = function() return getPowerConst().waterLevel.duration end,
	initCooldown = function() return getPowerConst().waterLevel.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().waterLevel.allowedGoldCarrier end,
    charges = function() return getPowerConst().waterLevel.charges end,
	rank = function() return getPowerConst().waterLevel.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
        notifyPowerActivated(player, state.name)
		raiseWaterEffect(player, getPowerConst().waterLevel.duration, 2)
	end,
	onDeactivated = function(player, vehicle, state)
		
	end	
}

if registerTemporaryPower then
    --registerTemporaryPower("flood", waterLevelPowerUp)
end
