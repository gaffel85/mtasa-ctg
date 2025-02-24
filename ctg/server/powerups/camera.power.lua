local cinematicCamera = {
	key = "cinematic",
	name = "Cinematic camera",
	cooldown = 20,
	duration = 10,
	initCooldown = 10,
	allowedGoldCarrier = true,
	onEnable = function(player)
		-- outputChatBox("superCar enabled "..getPlayerName(player))
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
        for i, otherPlayer in ipairs(getElementsByType("player")) do
            -- if the player is in a vehicle
            if otherPlayer ~= player then
                triggerClientEvent(otherPlayer, "setCinematicCameraAngle", otherPlayer)
            end
        end
	end,
	onDeactivated = function(player, vehicle, state)
		for i, otherPlayer in ipairs(getElementsByType("player")) do
            -- if the player is in a vehicle
            if otherPlayer ~= player then
                triggerClientEvent(otherPlayer, "resetCameraAngle", otherPlayer)
            end
        end
	end	
}

addPowerUp(cinematicCamera)