local function createWaterAt(x, y, z, size)
    southWest_X = x-size
    southWest_Y = y-size
    southEast_X = x+size
    southEast_Y = y-size
    northWest_X = x-size
    northWest_Y = y+size
    northEast_X = x+size
    northEast_Y = y+size

    -- outputServerLog(southWest_X, southWest_Y, height, southEast_X, southEast_Y, height, northWest_X, northWest_Y, height, northEast_X, northEast_Y, height)
    return createWater ( southWest_X, southWest_Y, height, southEast_X, southEast_Y, height, northWest_X, northWest_Y, height, northEast_X, northEast_Y, height )

end

function raiseWaterEffect(player, duration)
    setPreventDieFromWater(true)
    local duration = getPowerConst().waterLevel.duration
    local timeDeltas = 50
    

    local x, y, z = getElementPosition(player)
    -- Setting water properties.
    height = z - 20
    radius = 1000
    -- loop try to create water unitl not nil
    local water = nil
    while not (water and radius >= 10) do
        water = createWaterAt(x, y, z, radius)
        if radius < 200 then
            radius = radius - 10    
        else 
            radius = radius - 100    
        end
        
    end

    if not water then
        outputServerLog("Could not create water", southWest_X, southWest_Y, height, southEast_X, southEast_Y, height, northWest_X, northWest_Y, height, northEast_X, northEast_Y, height)
        return
    end

    setWaterLevel ( water, height )

    local level = height
    local totalHeightToRaise = 18
    local raisPart = 0.33333
    local repetitions = duration * 1000 / timeDeltas
    local steps = totalHeightToRaise / (repetitions * raisPart)
    local index = 0
    function drainSomeWater()
        if water then
            if index < repetitions * raisPart then
                level = level + steps
                setWaterLevel ( water, level )
            elseif index > 2 * repetitions * raisPart then
                level = level - steps
                setWaterLevel ( water, level )
            end
        end
        index = index + 1
        if (index >= repetitions - 1) then
            setPreventDieFromWater(false)
            if water then
                destroyElement(water)
            end
            water = nil
        end
    end
    setTimer ( drainSomeWater, timeDeltas, repetitions )
end

local waterLevelPowerUp = {
	key = "waterLevel",
	name = "Flood",
    desc = "Makes the sea level rise to 2m below you. Vehicles in the water will not be able to move until the water level is back to normal.",
	cooldown = function() return getPowerConst().waterLevel.cooldown end,
	duration = function() return getPowerConst().waterLevel.duration end,
	initCooldown = function() return getPowerConst().waterLevel.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().waterLevel.allowedGoldCarrier end,
	rank = function() return getPowerConst().waterLevel.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		raiseWaterEffect(player, waterLevelPowerUp.duration())
	end,
	onDeactivated = function(player, vehicle, state)
		
	end	
}

addPowerUp(waterLevelPowerUp)