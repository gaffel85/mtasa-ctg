local BOAT_MODEL = 452 -- Speeder
local checkTimers = {}
local isBoat = {}

local amphibiousPower = {
	key = "amphibious",
	name = "Amphibious",
    desc = "Raises water level and transforms you into a boat when submerged.",
    iconPath = "img/flood.png",
	cooldown = function() return getPowerConst().amphibious.cooldown end,
	duration = function() return getPowerConst().amphibious.duration end,
	initCooldown = function() return getPowerConst().amphibious.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().amphibious.allowedGoldCarrier end,
    charges = function() return getPowerConst().amphibious.charges end,
	rank = function() return getPowerConst().amphibious.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
        notifyPowerActivated(player, state.name)
        
        raiseWaterEffect(player, getPowerConst().amphibious.duration, 0)
        
        checkTimers[player] = setTimer(function(p)
            if not isElement(p) then return end

            local veh = getPedOccupiedVehicle(p)
            if not veh then return end

            if isElementInWater(veh) then
                if not isBoat[p] then
                    preventChangeFor(p)
                    setVehicleForPlayer(p, BOAT_MODEL, "Amphibious: Submerged")
                    isBoat[p] = true
                end
            end
        end, 500, 0, player)
	end,
	onDeactivated = function(player, vehicle, state)
		if isTimer(checkTimers[player]) then
            killTimer(checkTimers[player])
        end
        checkTimers[player] = nil
        
        if isBoat[player] then
            unpreventChangeFor(player)
            setVehicleForPlayer(player, getCurrentVehicle(), "Amphibious: Deactivated")
            isBoat[player] = false
        end
	end	
}

if registerTemporaryPower then
    registerTemporaryPower("amphibious", amphibiousPower)
end
