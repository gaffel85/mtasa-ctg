local duration = 16
local trafficChaos = {
	key = "chaos",
	name = "Traffic chaos",
	desc = "Randomly changes your opponent's vehicle every 2 seconds.",
	cooldown = 20,
	duration = duration,
	initCooldown = 1,
	allowedGoldCarrier = false,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
        -- loop over all players
		local times = duration / 2
		local index = 0
		setTimer(function()
			for i, otherPlayer in ipairs(getElementsByType("player")) do
				-- get the vehicle of the player
				local otherVehicle = getPedOccupiedVehicle(otherPlayer)
				-- if the player is in a vehicle
				if otherVehicle and otherPlayer ~= player then
					if index + 1 >= times then
						outputChatBox("Disabling chaos for "..getPlayerName(otherPlayer))
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