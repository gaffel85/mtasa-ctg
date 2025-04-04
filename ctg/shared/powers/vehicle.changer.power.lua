local superCarPowerUpOld = {
	key = "superCar",
	name = "Super car",
    desc = "Changes your vehicle to a super car for a short period of time.",
	cooldown = function() return getPowerConst().superCar.cooldown end,
	duration = function() return getPowerConst().superCar.duration end,
	initCooldown = function() return getPowerConst().superCar.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().superCar.allowedGoldCarrier end,
	charges = function() return getPowerConst().superCar.charges end,
	rank = function() return getPowerConst().superCar.rank end,
	onEnable = function(player)
		-- outputChatBox("superCar enabled "..getPlayerName(player))
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		preventChangeFor(player)
		setVehicleForPlayer(player, getPowerConst().superCar.model)
	end,
	onDeactivated = function(player, vehicle, state)
		unpreventChangeFor(player)
		setVehicleForPlayer(player, getCurrentVehicle())
	end	
}

local superCarPowerUp = {
	key = "superCar",
	name = "Super car",
    desc = "Changes your vehicle to a super car for a short period of time.",
    resourceKey = "vehicleTime",
	minBurn = 50,
	burnRate = 15,
	minResourceAmount = 100,
	cooldown = function() return getPowerConst().superCar.cooldown end,
	duration = function() return getPowerConst().superCar.duration end,
	initCooldown = function() return getPowerConst().superCar.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().superCar.allowedGoldCarrier end,
	charges = function() return getPowerConst().superCar.charges end,
	rank = function() return getPowerConst().superCar.rank end,
	onEnable = function(player)
		-- outputChatBox("superCar enabled "..getPlayerName(player))
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		preventChangeFor(player)
		setVehicleForPlayer(player, getPowerConst().superCar.model)
	end,
	onDeactivated = function(player, vehicle, state)
		unpreventChangeFor(player)
		setVehicleForPlayer(player, getCurrentVehicle())
	end	
}

local offoadPowerUpOld = {
	key = "offroad",
	name = "Offroad",
    desc = "Changes your vehicle to an offroad vehicle for a short period of time. Usable when climbing a hill or when you need more grip.",
	cooldown = function() return getPowerConst().offroad.cooldown end,
	duration = function() return getPowerConst().offroad.duration end,
    charges = function() return getPowerConst().offroad.charges end,
	initCooldown = function() return getPowerConst().offroad.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().offroad.allowedGoldCarrier end,
	rank = function() return getPowerConst().offroad.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		preventChangeFor(player)
		setVehicleForPlayer(player, 495)
	end,
	onDeactivated = function(player, vehicle, state)
		unpreventChangeFor(player)
		setVehicleForPlayer(player, getCurrentVehicle())
	end	
}

local offoadPowerUp = {
	key = "offroad",
	name = "Offroad",
    desc = "Changes your vehicle to an offroad vehicle for a short period of time. Usable when climbing a hill or when you need more grip.",
    resourceKey = "vehicleTime",
	minBurn = 50,
	burnRate = 10,
	minResourceAmount = 100,
	cooldown = function() return getPowerConst().offroad.cooldown end,
	duration = function() return getPowerConst().offroad.duration end,
    charges = function() return getPowerConst().offroad.charges end,
	initCooldown = function() return getPowerConst().offroad.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().offroad.allowedGoldCarrier end,
	rank = function() return getPowerConst().offroad.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		preventChangeFor(player)
		setVehicleForPlayer(player, 495)
	end,
	onDeactivated = function(player, vehicle, state)
		unpreventChangeFor(player)
		setVehicleForPlayer(player, getCurrentVehicle())
	end	
}

addPowerUp(superCarPowerUpOld)
addResourcePower(superCarPowerUp)
addPowerUp(offoadPowerUpOld)
addResourcePower(offoadPowerUp)