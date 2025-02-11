local goldCarrier
local oldGoldCarrier
local previousGoldCarrier
local previousGoldCarrierResetter

local vechicleHandlingLookup = {}

function getGoldCarrier()
    return goldCarrier
end

function setGoldCarrier(carrier)
    if (carrier == goldCarrier) then
        return
    end

    oldGoldCarrier = goldCarrier
    if (oldGoldCarrier) then
        removeVechicleHandling(oldGoldCarrier)
    end

    
    goldCarrier = carrier
    if (carrier) then
        setVechicleHandling(goldCarrier)
    end
end

function clearGoldCarrier()
    -- outputChatBox("Clear gold carrier!!!!")
    local tmpGoldCarrier = goldCarrier
    setGoldCarrier(nil)
    oldGoldCarrier = nil
    tillbakaKakaShield = false
    -- triggerClientEvent("onGoldCarrierChanged", nil, nil)

    -- ALways togheter. Remove trigger?
    -- triggerEvent("goldCarrierChanged", root, nil, tmpGoldCarrier)
    onGoldCarrierChanged( nil, tmpGoldCarrier)

    -- SHould be triggerClientEvent?
    triggerClientEvent("goldCarrierCleared", root)
end

function changeGoldCarrier(player)
    if (player == goldCarrier) then
        return
    end

    if ( player == oldGoldCarrier and tillbakaKakaShield == true) then
		-- outputChatBox("Did not change, tillbaka kaka")
		return
	end

	tillbakaKakaShield = true
	setTimer(function() 
		tillbakaKakaShield = false
	end, 5000, 1)


    setGoldCarrier(player)
    tillbakaKakaShield = true

	givePointsToPlayer(goldCarrier, 50)

    -- ALways togheter. Remove trigger?
    -- triggerEvent("goldCarrierChanged", root, goldCarrier, oldGoldCarrier)
    onGoldCarrierChanged( goldCarrier, oldGoldCarrier)

    triggerClientEvent("onGoldCarrierChanged", player, oldGoldCarrier)
    
	setTimer(function() 
		tillbakaKakaShield = false
	end, 5000, 1)
    
end

function removeVechicleHandling(oldCarrier)
    -- removeVehicleUpgrade(getPedOccupiedVehicle(oldGoldCarrier), 1009)
    local vechicle = getPedOccupiedVehicle(oldCarrier)
    if (not vechicle) then
        return
    end

    local originalHandling = vechicleHandlingLookup[getElementModel(vechicle)]
    if (originalHandling) then
        setVehicleHandling(vechicle, "mass", originalHandling.mass)
        setVehicleHandling(vechicle, "centerOfMass", originalHandling.centerOfMass)
        setVehicleHandling(vechicle, "maxVelocity", originalHandling.maxVelocity)
        setVehicleHandling(vechicle, "engineAcceleration", originalHandling.engineAcceleration)
        setVehicleHandling(vechicle, "brakeDeceleration", originalHandling.brakeDeceleration)
    end
end

function setVechicleHandling(carrier)
    local vehicle = getPedOccupiedVehicle(carrier)
    if (not vehicle or vehicle == false) then
        return
    end
    local currentMass = getVehicleHandling ( vehicle, "mass" )
    local currentCenterOfMass = getVehicleHandling ( vehicle, "centerOfMass" )
    local currentMaxVelocity = getVehicleHandling ( vehicle, "maxVelocity" )
    local currentEngineAcceleration = getVehicleHandling ( vehicle, "engineAcceleration" )
    local currentBrakeDeceleration = getVehicleHandling ( vehicle, "brakeDeceleration" )
    local vehicleId = getElementModel(vehicle)
    local currentHandling = {
        mass = currentMass,
        centerOfMass = currentCenterOfMass,
        maxVelocity = currentMaxVelocity,
        engineAcceleration = currentEngineAcceleration,
        brakeDeceleration = currentBrakeDeceleration
    }
    vechicleHandlingLookup[vehicleId] = currentHandling

    local newMass = currentMass + GOLD_MASS
    local newCenterOfMass = combineCenterOfMass(currentCenterOfMass, currentMass, GOLD_HEIGHT, 300)
    local newMaxVelocity = currentMaxVelocity * GOLD_HANDLING_COEFF
    local newEngineAcceleration = currentEngineAcceleration * GOLD_HANDLING_COEFF
    local newBrakeDeceleration = currentBrakeDeceleration * GOLD_HANDLING_COEFF

    setVehicleHandling(vehicle, "mass", newMass)
    setVehicleHandling(vehicle, "centerOfMass", newCenterOfMass)
    --setVehicleHandling(vehicle, "maxVelocity", newMaxVelocity)
    setVehicleHandling(vehicle, "engineAcceleration", newEngineAcceleration)
    setVehicleHandling(vehicle, "brakeDeceleration", newBrakeDeceleration)
end

function combineCenterOfMass( centerOfMass1, mass1, centerOfMassZ2, mass2 )
    return {
        [1] = centerOfMass1[1],
        [2] = centerOfMass1[2],
        [3] = (centerOfMass1[3] * mass1 + centerOfMassZ2 * mass2) / (mass1 + mass2)
    }
end