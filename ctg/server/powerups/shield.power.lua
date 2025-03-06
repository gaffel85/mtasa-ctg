local cinematicCamera = {
	key = "shield",
	name = "Gold shield",
    desc = "Protects you from losing the gold if hit by another player.",
	cooldown = 3,
	duration = 6,
    charges = 3,
	initCooldown = 0,
	allowedGoldCarrier = true,
	rank = 3,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		addShieldedPlayer(player)
		triggerClientEvent(getRootElement(), "onShieldAddedFromServer", getRootElement(), player)
	end,
	onDeactivated = function(player, vehicle, state)
		removeShieldedPlayer(player)
		triggerClientEvent(getRootElement(), "onShieldRemovedFromServer", resourceRoot, player)
	end	
}

addPowerUp(cinematicCamera)