local worldGravityPower = {
	key = "worldgravity",
	name = "Low world gravity",
    desc = "Changes the world gravity to a lower value for a short period of time.",
	cooldown = function() return getPowerConst().worldgravity.cooldown end,
	duration = function() return getPowerConst().worldgravity.duration end,
    charges = function() return getPowerConst().worldgravity.charges end,
	initCooldown = function() return getPowerConst().worldgravity.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().worldgravity.allowedGoldCarrier end,
	rank = function() return getPowerConst().worldgravity.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		setGravity(getPowerConst().worldgravity.gravity)
	end,
	onDeactivated = function(player, vehicle, state)
		setGravity(0.008)
	end	
}

addPowerUp(worldGravityPower)