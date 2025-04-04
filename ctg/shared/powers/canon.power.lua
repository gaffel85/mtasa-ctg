local factor = 3

local canonPushPowerupOld = {
	key = "canon",
	name = "Canon ball",
    desc = "Instantly increase the speed of your vehicle with a factor of 3. The effect is instanst and will not affect your speed over time.",
	cooldown = function() return getPowerConst().canon.cooldown end,
	duration = function() return getPowerConst().canon.duration end,
    charges = function() return getPowerConst().canon.charges end,
	initCooldown = function() return getPowerConst().canon.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().canon.allowedGoldCarrier end,
	rank = function() return getPowerConst().canon.rank end,
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

local canonPushPowerup = {
	key = "canon",
	name = "Canon ball",
    desc = "Instantly increase the speed of your vehicle with a factor of 3. The effect is instanst and will not affect your speed over time.",
	resourceKey = "overcharge",
	minBurn = 100,
	burnRate = 0,
	minResourceAmount = 100,
	cooldown = function() return 3 end,
	duration = function() return getPowerConst().canon.duration end,
    charges = function() return nil end,
	initCooldown = function() return 0.1 end,
	allowedGoldCarrier = function() return getPowerConst().canon.allowedGoldCarrier end,
	rank = function() return getPowerConst().canon.rank end,
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


addPowerUp(canonPushPowerupOld)
addResourcePower(canonPushPowerup)