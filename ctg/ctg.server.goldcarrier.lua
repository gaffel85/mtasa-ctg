local oldGoldCarrier
local previousGoldCarrier
local previousGoldCarrierResetter

local tillbakaKakaShield = false
local shieldedPlayer = nil

local vechicleHandlingLookup = {}

function setGoldCarrier(carrier)
    outputServerLog("Setting gold carrier to "..inspect(carrier))
    if (carrier == getGoldCarrier()) then
        outputServerLog("Gold carrier will not changed to "..inspect(carrier))
        return
    end

    oldGoldCarrier = setGoldCarrierData(carrier)
    if (oldGoldCarrier) then
        --removeVechicleHandling(oldGoldCarrier)
    end

    outputServerLog("Gold carrier set to "..inspect(getGoldCarrier))
    if (carrier) then
        --setVechicleHandling(getGoldCarrier())
    end
end

function shieldPlayer(player)
    tillbakaKakaShield = true
    shieldedPlayer = player
    addShieldedPlayer(player, 10000, 2)
end

function clearShield()
    if (shieldedPlayer) then
        removeShieldedPlayer(shieldedPlayer)
    end
    tillbakaKakaShield = false
    shieldedPlayer = nil
end

function isShielded(player)
    return tillbakaKakaShield
end

function clearGoldCarrier()
    -- outputChatBox("Clear gold carrier!!!!")
    local tmpGoldCarrier = getGoldCarrier()
    setGoldCarrier(nil)
    oldGoldCarrier = nil
    clearShield()
    -- triggerClientEvent("onGoldCarrierChanged", nil, nil)

    -- ALways togheter. Remove trigger?
    -- triggerEvent("goldCarrierChanged", root, nil, tmpGoldCarrier)
    -- outputChatBox("goldcarrier.clearGoldCarrier, gold carrier: "..inspect(getGoldCarrier()))
    onGoldCarrierChanged( nil, tmpGoldCarrier)
    handlePowersForGoldCarrierChangedResourceBased(nil, tmpGoldCarrier)

    -- SHould be triggerClientEvent?
    triggerClientEvent("goldCarrierCleared", root)
end

function changeGoldCarrier(player)
    if (player == getGoldCarrier()) then
        return
    end

    if ( isShielded(getGoldCarrier()) == true) then
		-- outputChatBox("Did not change, tillbaka kaka")
		return
	end

	shieldPlayer(player)
	setTimer(function() 
		clearShield()
	end, getConst().tillbakaKakatime, 1)

    setGoldCarrier(player)
    --tillbakaKakaShield = true

	givePointsToPlayer(getGoldCarrier(), 50)

    -- ALways togheter. Remove trigger?
    -- triggerEvent("goldCarrierChanged", root, getGoldCarrier(), oldGoldCarrier)
    onGoldCarrierChanged( getGoldCarrier(), oldGoldCarrier)
    handlePowersForGoldCarrierChangedResourceBased(getGoldCarrier(), oldGoldCarrier)

    triggerClientEvent("onGoldCarrierChanged", player, oldGoldCarrier)    
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

    local newMass = currentMass + getConst().goldMass
    local newCenterOfMass = combineCenterOfMass(currentCenterOfMass, currentMass, getConst().goldHeight, 300)
    local newMaxVelocity = currentMaxVelocity * getConst().goldHandlingCoeff
    local newEngineAcceleration = currentEngineAcceleration * getConst().goldHandlingCoeff
    local newBrakeDeceleration = currentBrakeDeceleration * getConst().goldHandlingCoeff

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