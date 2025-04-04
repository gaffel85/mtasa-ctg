local jumpPushPowerupOld = {
	key = "jump",
	name = "K.I.T.T. Jump",
    desc = "Your car will jump like K.I.T.T. from Knight Rider, but you will never look as cool as David Hasselhoff.",
	cooldown = function() return getPowerConst().jump.cooldown end,
	duration = function() return getPowerConst().jump.duration end,
    charges = function() return getPowerConst().jump.charges end,
	initCooldown = function() return getPowerConst().jump.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().jump.allowedGoldCarrier end,
	rank = function() return getPowerConst().jump.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		local vx, vy, vz = getElementVelocity(vehicle)
        local velocityVector = { x = vx, y = vy, z = vz }
        local newVelocityVector = { x = vx, y = vy, z = vz + getPowerConst().jump.height }
        setElementVelocity(vehicle, newVelocityVector.x, newVelocityVector.y, newVelocityVector.z)
	end,
	onDeactivated = function(player, vehicle, state)
		
	end	
}

local jumpPushPowerup = {
	key = "jump",
	name = "K.I.T.T. Jump",
    desc = "Your car will jump like K.I.T.T. from Knight Rider, but you will never look as cool as David Hasselhoff.",
	resourceKey = "energy",
	minBurn = 50,
	burnRate = 0,
	minResourceAmount = 50,
	cooldown = function() return 0.1 end,
	duration = function() return 0.1 end,
    charges = function() return nil end,
	initCooldown = function() return 0.1 end,
	allowedGoldCarrier = function() return getPowerConst().jump.allowedGoldCarrier end,
	rank = function() return getPowerConst().jump.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		local vx, vy, vz = getElementVelocity(vehicle)
        local velocityVector = { x = vx, y = vy, z = vz }
        local newVelocityVector = { x = vx, y = vy, z = vz + getPowerConst().jump.height }
        setElementVelocity(vehicle, newVelocityVector.x, newVelocityVector.y, newVelocityVector.z)
	end,
	onDeactivated = function(player, vehicle, state)
		
	end	
}

addPowerUp(jumpPushPowerupOld)
addResourcePower(jumpPushPowerup)