local trafficChaos = {
	key = "chaos",
	name = "Traffic chaos",
	desc = "Randomly changes your opponent's vehicle every 2 seconds.",
	cooldown = function() return getPowerConst().chaos.cooldown end,
	duration = function() return getPowerConst().chaos.duration end,
	initCooldown = function() return getPowerConst().chaos.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().chaos.allowedGoldCarrier end,
	charges = function() return getPowerConst().nitro.charges end,
	rank = function() return getPowerConst().chaos.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
        -- loop over all players
		local times = getPowerConst().chaos.duration / 2
		local index = 0
		setTimer(function()
			for i, otherPlayer in ipairs(getElementsByType("player")) do
				-- get the vehicle of the player
				local otherVehicle = getPedOccupiedVehicle(otherPlayer)
				-- if the player is in a vehicle
				if otherVehicle and otherPlayer ~= player then
					if index + 1 >= times then
				-- outputChatBox("Disabling chaos for "..getPlayerName(otherPlayer))
						unpreventChangeFor(otherPlayer)
						setElementModel(otherVehicle, getCurrentVehicle())
					else
						preventChangeFor(otherPlayer)
						setElementModel(otherVehicle, getRandomVehicle())
					end
				end
			end
			index = index + 1
		end, 2000, times)
	end,
	onDeactivated = function(player, vehicle, state)
        
	end	
}

addPowerUp(trafficChaos)