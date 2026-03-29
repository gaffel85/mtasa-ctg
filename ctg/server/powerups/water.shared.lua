function createWaterAt(x, y, z, size, height)
    local southWest_X = x-size
    local southWest_Y = y-size
    local southEast_X = x+size
    local southEast_Y = y-size
    local northWest_X = x-size
    local northWest_Y = y+size
    local northEast_X = x+size
    local northEast_Y = y+size

    return createWater(southWest_X, southWest_Y, height, southEast_X, southEast_Y, height, northWest_X, northWest_Y, height, northEast_X, northEast_Y, height)
end

function raiseWaterEffect(player, duration, belowPlayer, onTick, onFinish)
    setPreventDieFromWater(true)
    local timeDeltas = 50
    
    local waterStart = 20
    local x, y, z = getElementPosition(player)
    local height = z - waterStart
    local radius = 1000
    local water = nil
    
    while not (water and radius >= 10) do
        water = createWaterAt(x, y, z, radius, height)
        if radius < 200 then
            radius = radius - 10    
        else 
            radius = radius - 100    
        end
    end

    if not water then
        return nil
    end

    setWaterLevel(water, height)

    local level = height
    local totalHeightToRaise = waterStart - belowPlayer
    local raisPart = 0.33333
    local repetitions = duration * 1000 / timeDeltas
    local steps = totalHeightToRaise / (repetitions * raisPart)
    local index = 0

    local function drainSomeWater()
        if water then
            if index < repetitions * raisPart then
                level = level + steps
                setWaterLevel(water, level)
            elseif index > 2 * repetitions * raisPart then
                level = level - steps
                setWaterLevel(water, level)
            end
            
            if onTick then
                onTick(water, level)
            end
        end
        
        index = index + 1
        if (index >= repetitions - 1) then
            setPreventDieFromWater(false)
            if water then
                destroyElement(water)
            end
            water = nil
            if onFinish then
                onFinish()
            end
        end
    end
    
    setTimer(drainSomeWater, timeDeltas, repetitions)
    return water
end
