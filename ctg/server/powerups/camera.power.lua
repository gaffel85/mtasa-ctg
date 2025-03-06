local cinematicCamera = {
	key = "cinematic",
	name = "Cinematic camera",
    desc = "Changes to a helicopter view for all your opponents. This will make it harder for them to see where they drive and affect there accuracy.",
	cooldown = 3,
	duration = 3,
	initCooldown = 0,
	allowedGoldCarrier = true,
	rank = 3,
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