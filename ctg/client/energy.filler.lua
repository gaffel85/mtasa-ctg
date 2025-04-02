DGS = exports.dgs --shorten the export function prefix

local energyBar = nil
local RESOURCES_KEY = "RESOURCES_KEY"
local energyResourceKey = "energy"
local timerDiff = 50
local fillRate = 10

local energyState = {
    key = energyResourceKey,
    currentAmount = 0,
    lastSendToServer = 0,
    isBurning = false,
    burningRate = 0
}

function getClientState(resouceKey)
    return energyState
end

function createEnergyBar()
    energyBar = guiCreateProgressBar( 0.8, 0.5, 0.1, 0.04, true, nil ) --create the gui-progressbar
    dsgEnergyBar = DGS:dgsCreateProgressBar(0.8, 0.55, 0.1, 0.04, true, nil)
end

function getEnergyBar()
    if energyBar == nil then
        createEnergyBar()
    end
    return energyBar, dsgEnergyBar
end

function setEnergyBarProgress(percentage)   
    local energyBar, dsgEnergyBar = getEnergyBar()
    guiProgressBarSetProgress(energyBar, percentage)
    DGS:dgsProgressBarSetProgress(dsgEnergyBar, percentage)
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

function fillBarPeriodically()
    local resource = getResourceData(energyResourceKey)
    if not resource then
        return
    end

    if energyState.isBurning then
        energyState.currentAmount = energyState.currentAmount - (energyState.burningRate * timerDiff / 1000)
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

    local percentage = 100 * energyState.currentAmount / resource.capacity
    setEnergyBarProgress(percentage)
end

addEvent("resourceInUseFromServer", true) -- (resourceKey, burnRate)
addEventHandler("resourceInUseFromServer", getRootElement(), function(resourceKey, burnRate, minBurn)
    outputConsole("Burning "..resourceKey.." with rate "..burnRate)

    local clientResourceState = getClientState(resourceKey)
    if not clientResourceState then
        return
    end
    
    if burnRate == 0 then
        if minBurn then
            clientResourceState.currentAmount = math.max(clientResourceState.currentAmount - minBurn, 0)
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
        return
    end

    clientResourceState.isBurning = false
    clientResourceState.burningRate = 0
    updateServerWithLatestValues(clientResourceState)
end)

setEnergyBarProgress(0)
setTimer(fillBarPeriodically, timerDiff, 0)