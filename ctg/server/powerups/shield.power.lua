local cinematicCamera = {
	key = "shield",
	name = "Gold shield",
    desc = "Protects you from losing the gold if hit by another player.",
	cooldown = 3,
	duration = 3,
    charges = 1,
	initCooldown = 0,
	allowedGoldCarrier = true,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
        triggerClientEvent(getRootElement(), "onShieldAddedFromServer", getRootElement(), player)
	end,
	onDeactivated = function(player, vehicle, state)
		triggerClientEvent(getRootElement(), "onShieldRemovedFromServer", getRootElement(), player)
	end	
}

addPowerUp(cinematicCamera)