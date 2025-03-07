local helicopterPowerup = {
	key = "helicopter",
	name = "Helicopter",
    desc = "Changes your vehicle to a helicopter for a short period of time.",
	cooldown = function() return getPowerConst().helicopter.cooldown end,
	duration = function() return getPowerConst().helicopter.duration end,
    charges = function() return getPowerConst().helicopter.charges end,
	initCooldown = function() return getPowerConst().helicopter.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().helicopter.allowedGoldCarrier end,
	rank = function() return getPowerConst().helicopter.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		preventChangeFor(player)
		setElementModel(vehicle, 488)
	end,
	onDeactivated = function(player, vehicle, state)
		unpreventChangeFor(player)
		setElementModel(vehicle, getCurrentVehicle())
	end	
}


local planePowerup = {
	key = "plane",
	name = "Plane",
    desc = "Changes your vehicle to a plane for a short period of time.",
	cooldown = function() return getPowerConst().plane.cooldown end,
	duration = function() return getPowerConst().plane.duration end,
    charges = function() return getPowerConst().plane.charges end,
	initCooldown = function() return getPowerConst().plane.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().plane.allowedGoldCarrier end,
	rank = function() return getPowerConst().plane.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		preventChangeFor(player)
		setElementModel(vehicle, 593)
	end,
	onDeactivated = function(player, vehicle, state)
		unpreventChangeFor(player)
		setElementModel(vehicle, getCurrentVehicle())
	end	
}

local offoadPowerUp = {
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
		setElementModel(vehicle, 495)
	end,
	onDeactivated = function(player, vehicle, state)
		unpreventChangeFor(player)
		setElementModel(vehicle, getCurrentVehicle())
	end	
}

local superCarPowerUp = {
	key = "superCar",
	name = "Super car",
    desc = "Changes your vehicle to a super car for a short period of time.",
	cooldown = function() return getPowerConst().superCar.cooldown end,
	duration = function() return getPowerConst().superCar.duration end,
	initCooldown = function() return getPowerConst().superCar.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().superCar.allowedGoldCarrier end,
	rank = function() return getPowerConst().superCar.rank end,
	onEnable = function(player)
		-- outputChatBox("superCar enabled "..getPlayerName(player))
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		preventChangeFor(player)
		setElementModel(vehicle, SUPER_CAR_MODEL)
	end,
	onDeactivated = function(player, vehicle, state)
		unpreventChangeFor(player)
		setElementModel(vehicle, getCurrentVehicle())
	end	
}

local bussesForEveryone = {
	key = "busses",
	name = "Bustrip",
    desc = "Changes all opponent's vehicles to busses for a short period of time.",
	cooldown = function() return getPowerConst().busses.cooldown end,
	duration = function() return getPowerConst().busses.duration end,
	initCooldown = function() return getPowerConst().busses.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().busses.allowedGoldCarrier end,
	rank = function() return getPowerConst().busses.rank end,
	onEnable = function(player)
		-- outputChatBox("superCar enabled "..getPlayerName(player))
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
        -- loop over all players
        for i, otherPlayer in ipairs(getElementsByType("player")) do
            -- get the vehicle of the player
            local otherVehicle = getPedOccupiedVehicle(otherPlayer)
            -- if the player is in a vehicle
            if otherVehicle and otherPlayer ~= player then
                preventChangeFor(otherPlayer)
		        setElementModel(otherVehicle, 431)
            end
        end
	end,
	onDeactivated = function(player, vehicle, state)
         -- loop over all players
         for i, otherPlayer in ipairs(getElementsByType("player")) do
            -- get the vehicle of the player
            local otherVehicle = getPedOccupiedVehicle(otherPlayer)
            -- if the player is in a vehicle
            if otherVehicle and otherPlayer ~= player then
                unpreventChangeFor(otherPlayer)
		        setElementModel(otherVehicle, getCurrentVehicle())
            end
        end
	end	
}

addPowerUp(helicopterPowerup)
addPowerUp(superCarPowerUp)
addPowerUp(offoadPowerUp)
addPowerUp(bussesForEveryone)
addPowerUp(planePowerup)