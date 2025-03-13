local cinematicCamera = {
	key = "shield",
	name = "Gold shield",
    desc = "Protects you from losing the gold if hit by another player.",
	cooldown = function() return getPowerConst().shield.cooldown end,
	duration = function() return getPowerConst().shield.duration end,
    charges = function() return getPowerConst().shield.charges end,
	initCooldown = function() return getPowerConst().shield.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().shield.allowedGoldCarrier end,
	rank = function() return getPowerConst().shield.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		addShieldedPlayer(player, 1, 2)
	end,
	onDeactivated = function(player, vehicle, state)
		removeShieldedPlayer(player, 1, 2)
	end	
}

addPowerUp(cinematicCamera)