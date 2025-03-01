
local helicopterPowerup = {
	key = "helicopter",
	name = "Helicopter",
    desc = "Changes your vehicle to a helicopter for a short period of time.",
	cooldown = 20,
	duration = 8,
    charges = -1,
	initCooldown = 1,
	allowedGoldCarrier = false,
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
	cooldown = 20,
	duration = 4,
    charges = 1,
	initCooldown = 1,
	allowedGoldCarrier = false,
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
	cooldown = 20,
	duration = 8,
    charges = -1,
	initCooldown = 1,
	allowedGoldCarrier = false,
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
	cooldown = 20,
	duration = 20,
	initCooldown = 10,
	allowedGoldCarrier = false,
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
	cooldown = 20,
	duration = 20,
	initCooldown = 10,
	allowedGoldCarrier = false,
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