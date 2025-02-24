local factor = 3

local canonPushPowerup = {
	key = "canon",
	name = "Canon ball",
	cooldown = 5,
	duration = 1,
    charges = 1,
	initCooldown = 1,
	allowedGoldCarrier = false,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		local vx, vy, vz = getElementVelocity(vehicle)
        local velocityVector = { x = vx, y = vy, z = vz }
        local newVelocityVector = { x = vx * factor, y = vy * factor, z = vz * factor }
        setElementVelocity(vehicle, newVelocityVector.x, newVelocityVector.y, newVelocityVector.z)
	end,
	onDeactivated = function(player, vehicle, state)
		
	end	
}

addPowerUp(canonPushPowerup)