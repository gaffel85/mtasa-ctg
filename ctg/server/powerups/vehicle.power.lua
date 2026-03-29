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
		setVehicleForPlayer(player, 488, "Power activated: Helicopter")
	end,
	onDeactivated = function(player, vehicle, state)
		if isElement(player) then
			unpreventChangeFor(player)
			setVehicleForPlayer(player, getCurrentVehicle(), "Power deactivated: Helicopter")
		end
	end	
}

local bussesForEveryone = {
	key = "busses",
	name = "Bustrip",
    desc = "Changes all vehicles to busses for a short period of time.",
	iconPath = "img/busses.png",
	cooldown = function() return getPowerConst().busses.cooldown end,
	duration = function() return getPowerConst().busses.duration end,
	initCooldown = function() return getPowerConst().busses.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().busses.allowedGoldCarrier end,
	charges = function() return getPowerConst().superCar.charges end,
	rank = function() return getPowerConst().busses.rank end,
	onEnable = function(player)
		-- outputChatBox("superCar enabled "..getPlayerName(player))
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		notifyPowerActivated(player, "Bustrip")
        -- loop over all players
        for i, otherPlayer in ipairs(getElementsByType("player")) do
            -- get the vehicle of the player
            local otherVehicle = getPedOccupiedVehicle(otherPlayer)
            -- if the player is in a vehicle
            if otherVehicle and otherPlayer ~= player then
                preventChangeFor(otherPlayer)
		        setVehicleForPlayer(otherPlayer, 431, "Power activated: Bustrip by " .. (isElement(player) and getPlayerName(player) or "Unknown"))
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
		        setVehicleForPlayer(otherPlayer, getCurrentVehicle(), "Power deactivated: Bustrip")
            end
        end
	end	
}

if registerTemporaryPower then
    --registerTemporaryPower("bus_transform", bussesForEveryone)
end
