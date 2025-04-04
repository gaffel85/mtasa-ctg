local RESOURCES_KEY = "RESOURCES_KEY"
local energyResourceKey = "energy"
local overchargeResourceKey = "overcharge"
local timerDiff = 50
local fillRate = 10

local energyState = {
    key = energyResourceKey,
    currentAmount = 0,
    lastSendToServer = 0,
    isBurning = false,
    burningRate = 0
}

local overchargeState = {
    key = overchargeResourceKey,
    currentAmount = 0,
    lastSendToServer = 0,
    isBurning = false,
    burningRate = 0
}

function getClientState(resouceKey)
    if resouceKey == energyState.key then
        return energyState
    elseif resouceKey == overchargeState.key then
        return overchargeState
    end
    return nil
end

function getResourceData(resourceKey)
    local resources = getElementData(resourceRoot, RESOURCES_KEY)
    if not resources then
        outputConsole("Could not get energy resources")
        return nil
    end

    for i, resource in ipairs(resources) do
        if resource.key == resourceKey then
            return resource
        end
    end

    outputConsole("Could not get energy resource")
    return nil
end

function updateServerWithLatestValues(clientResourceState)
    local resource = getResourceData(clientResourceState.key)
    if not resource then
        return
    end

    local secondsUntilEnd = (resource.capacity - clientResourceState.currentAmount) / fillRate
    if clientResourceState.isBurning then
        secondsUntilEnd = clientResourceState.currentAmount / clientResourceState.burningRate
    end
    
    triggerServerEvent("energyAmountChangedFromClient", resourceRoot, clientResourceState.key, clientResourceState.currentAmount, secondsUntilEnd, clientResourceState.isBurning, clientResourceState.burningRate, fillRate)
end

function shouldUpdateServer(resource, clientResourceState)
    if clientResourceState.currentAmount == 0 and clientResourceState.lastSendToServer > 0 then
        return true
    end
    if clientResourceState.currentAmount == resource.capacity and clientResourceState.lastSendToServer < resource.capacity then
        return true
    end

    for i, power in ipairs(findPowersWithResource(resource.key)) do
        if clientResourceState.lastSendToServer < power.minResourceAmount and clientResourceState.currentAmount >= power.minResourceAmount then
            return true
        end
        if clientResourceState.lastSendToServer >= power.minResourceAmount and clientResourceState.currentAmount < power.minResourceAmount then
            return true
        end
    end

    return false
end

local function enableDisableUi()
    for i, power in ipairs(findPowersWithResource(resource.key)) do
        if power.key == "nitro" then
            setNitroEnabled(energyState.currentAmount >= power.minResourceAmount
        else if power.key = "jump" then
            setJumpEnabled(energyState.currentAmount >= power.minResourceAmount)
        else if power.key = "canon" then
            setCanonEnabled(overchargeState.currentAmount >= power.minResourceAmount)
        end
    end
end

function updateOverchargeProgress(overchargeResource)
    if not overchargeResource then
        overchargeResource = getResourceData(overchargeResourceKey)
        if not overchargeResource then
            return
        end
    end

    local percentage = 100 * overchargeState.currentAmount / overchargeResource.capacity
    setOverChargeBarProgress(percentage)
end

function addToOverCharge(amount)
    local resource = getResourceData(overchargeResourceKey)
    if not resource then
        return
    end

    if not overchargeState.isBurning then
        overchargeState.currentAmount = overchargeState.currentAmount + amount
        if overchargeState.currentAmount > resource.capacity then
            overchargeState.currentAmount = resource.capacity
        end
    end

    if (shouldUpdateServer(resource, overchargeState)) then
        overchargeState.lastSendToServer = overchargeState.currentAmount
        updateServerWithLatestValues(overchargeState)
    end

    updateOverchargeProgress(resource)
end

function fillEnergyPeriodically()
    local resource = getResourceData(energyResourceKey)
    if not resource then
        return
    end

    if energyState.isBurning then
        local burnAmount = (energyState.burningRate * timerDiff / 1000)
        if energyState.currentAmount > 0 then
            addToOverCharge(burnAmount * 3)
        end

        energyState.currentAmount = energyState.currentAmount - burnAmount
        if energyState.currentAmount < 0 then
            energyState.currentAmount = 0
        end
    else
        energyState.currentAmount = energyState.currentAmount + (fillRate * timerDiff / 1000)
        if energyState.currentAmount > resource.capacity then
            energyState.currentAmount = resource.capacity
        end
    end

    if (shouldUpdateServer(resource, energyState)) then
        energyState.lastSendToServer = energyState.currentAmount
        updateServerWithLatestValues(energyState)
    end
    enableDisableUi()

    local percentage = 100 * energyState.currentAmount / resource.capacity
    setEnergyBarProgress(percentage)
end

addEvent("resourceInUseFromServer", true) -- (resourceKey, burnRate)
addEventHandler("resourceInUseFromServer", getRootElement(), function(resourceKey, burnRate, minBurn)
    outputConsole("Burning "..resourceKey.." with rate "..burnRate)

    local clientResourceState = getClientState(resourceKey)
    if not clientResourceState then
        outputConsole("Could not get client resource state in resourceInUseFromServer with key "..resourceKey)
        return
    end
    
    if burnRate == 0 then
        if minBurn then
            clientResourceState.currentAmount = math.max(clientResourceState.currentAmount - minBurn, 0)
            if resourceKey == overchargeResourceKey then
                updateOverchargeProgress()
            end
        end
    else
        clientResourceState.burningRate = burnRate
        clientResourceState.isBurning = true
    end
    updateServerWithLatestValues(clientResourceState)
end)

addEvent("resourceNotInUseFromServer", true) -- (resourceKey, totalAmount)
addEventHandler("resourceNotInUseFromServer", getRootElement(), function(resourceKey, totalAmount)
    outputConsole("Not burning "..resourceKey)

    local clientResourceState = getClientState(resourceKey)
    if not clientResourceState then
        outputConsole("Could not get client resource state in resourceNotInUseFromServer with key "..resourceKey)
        return
    end

    clientResourceState.isBurning = false
    clientResourceState.burningRate = 0
    updateServerWithLatestValues(clientResourceState)
end)

local energyResource = getResourceData(energyResourceKey)
if energyResource then
    energyState.currentAmount = energyResource.initialCapacity
    setEnergyBarProgress(100 * energyState.currentAmount / energyResource.capacity)
end

local overchargeResource = getResourceData(overchargeResourceKey)
if overchargeResource then
    overchargeState.currentAmount = overchargeResource.initialCapacity
    updateOverchargeProgress(overchargeResource)
end

setTimer(fillEnergyPeriodically, timerDiff, 0)