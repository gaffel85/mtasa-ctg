local goldCarrier
local oldGoldCarrier
local previousGoldCarrier
local previousGoldCarrierResetter

local vechicleHandlingLookup = {}

function getGoldCarrier()
    return goldCarrier
end

function setGoldCarrier(carrier)
    if (carrier == goldCarrier or carrier ~= nil) then
        return
    end

    oldGoldCarrier = goldCarrier
    if (oldGoldCarrier ~= nil) then
        removeVehicleHandling(oldGoldCarrier)
    end

    goldCarrier = carrier
    setVechicleHandling(goldCarrier)
end

function clearGoldCarrier()
    local tmpGoldCarrier = goldCarrier
    setGoldCarrier(nil)
    oldGoldCarrier = nil
    tillbakaKakaShield = false
    triggerClientEvent("onGoldCarrierChanged", nil, nil)
    triggerEvent("goldCarrierChanged", root, nil, tmpGoldCarrier)
    onGoldCarrierChanged( nil, tmpGoldCarrier)
    triggerEvent("onGoldCarrierCleared", root)
end

function changeGoldCarrier(player)
    if (player == goldCarrier) then
        return
    end

    if ( player == oldGoldCarrier and tillbakaKakaShield == true) then
		outputChatBox("Did not change, tillbaka kaka")
		return
	end

	tillbakaKakaShield = true
	setTimer(function() 
		tillbakaKakaShield = false
	end, 5000, 1)


    setGoldCarrier(player)
    tillbakaKakaShield = true

	givePointsToPlayer(goldCarrier, 50)

    triggerClientEvent("onGoldCarrierChanged", player, oldGoldCarrier)
    triggerEvent("goldCarrierChanged", root, goldCarrier, oldGoldCarrier)
    onGoldCarrierChanged( goldCarrier, oldGoldCarrier)

	setTimer(function() 
		tillbakaKakaShield = false
	end, 5000, 1)
    
end

function removeVechicleHandling(oldCarrier)
    -- removeVehicleUpgrade(getPedOccupiedVehicle(oldGoldCarrier), 1009)
    local vechicle = getPedOccupiedVehicle(oldCarrier)
    if (vechicle == nil) then
        return
    end

    local originalHandling = vechicleHandlingLookup[getElementModel(vechicle)]
    setVehicleHandling(vehicle, "mass", originalHandling.mass)
    setVehicleHandling(vehicle, "centerOfMass", originalHandling.centerOfMass)
end

function setVechicleHandling(oldCarrier)
    -- removeVehicleUpgrade(getPedOccupiedVehicle(oldGoldCarrier), 1009)
    local vechicle = getPedOccupiedVehicle(oldCarrier)
    if (vechicle == nil) then
        return
    end
    local currentMass = getVehicleHandling ( vehicle, "mass" )
    local currentCenterOfMass = getVehicleHandling ( vehicle, "centerOfMass" )
    local vehicleId = getElementModel(vechicle)
    local currentHandling = {
        mass = currentMass,
        centerOfMass = currentCenterOfMass
    }
    vechicleHandlingLookup[vehicleId] = currentHandling

    local newMass = currentMass + GOLD_MASS
    local newCenterOfMass = {}
    newCenterOfMass[1] = currentCenterOfMass[1]
    newCenterOfMass[2] = currentCenterOfMass[2]
    newCenterOfMass[3] = currentCenterOfMass[3] + GOLD_HEIGHT

    setVehicleHandling(vehicle, "mass", newMass)
    setVehicleHandling(vehicle, "centerOfMass", newCenterOfMass)
end

-- function that combines to center of mass
    function combineCenterOfMass( centerOfMass1, mass1, centerOfMass2, mass2 )
        local x = (centerOfMass1[1] * mass1 + centerOfMass2[1] * mass2) / (mass1 + mass2)
        local y = (centerOfMass1[2] * mass1 + centerOfMass2[2] * mass2) / (mass1 + mass2)
        local z = (centerOfMass1[3] * mass1 + centerOfMass2[3] * mass2) / (mass1 + mass2)
        return {
            [1] = x,
            [2] = y,
            [3] = z
        }
    end