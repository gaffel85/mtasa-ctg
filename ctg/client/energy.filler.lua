local energyBar = nil
local RESOURCES_KEY = "RESOURCES_KEY"
local energyResourceKey = "energy"
local currentAmount = 0
local timerDiff = 50
local fillRate = 10
local sendToServerDiff = 10
local lastSendToServer = 0
local isBurning = false
local burningRate = 0

function createEnergyBar()
    energyBar = guiCreateProgressBar( 0.8, 0.5, 0.1, 0.04, true, nil ) --create the gui-progressbar
end

function getEnergyBar()
    if energyBar == nil then
        createEnergyBar()
    end
    return energyBar
end

function setEnergyBarProgress(percentage)
    guiProgressBarSetProgress(getEnergyBar(), percentage)
end

function getEnergyResource()
    local resources = getElementData(resourceRoot, RESOURCES_KEY)
    if not resources then
        outputConsole("Could not get energy resources")
        return nil
    end

    for i, resource in ipairs(resources) do
        if resource.key == energyResourceKey then
            return resource
        end
    end

    outputConsole("Could not get energy resource")
    return nil
end

function updateServerWithLatestValues()
    local resource = getEnergyResource()
    if not resource then
        return
    end
    local secondsUntilEnd = (resource.capacity - currentAmount) / fillRate
    if isBurning then
        secondsUntilEnd = currentAmount / burningRate
    end
    
    triggerServerEvent("energyAmountChangedFromClient", resourceRoot, energyResourceKey, currentAmount, secondsUntilEnd, isBurning, burningRate, fillRate)
end

function shouldUpdateServer(resource)
    if currentAmount == 0 and lastSendToServer > 0 then
        return true
    end
    if currentAmount == resource.capacity and lastSendToServer < resource.capacity then
        return true
    end

    for i, power in ipairs(findPowersWithResource(resource.key)) do
        if lastSendToServer < power.minResourceAmount and currentAmount >= power.minResourceAmount then
            return true
        end
        if lastSendToServer >= power.minResourceAmount and currentAmount < power.minResourceAmount then
            return true
        end
    end

    return math.abs(currentAmount - lastSendToServer) >= sendToServerDiff
end

function fillBarPeriodically()
    local resource = getEnergyResource()
    if not resource then
        return
    end

    if isBurning then
        currentAmount = currentAmount - (burningRate * timerDiff / 1000)
        if currentAmount < 0 then
            currentAmount = 0
        end
    else
        currentAmount = currentAmount + (fillRate * timerDiff / 1000)
        if currentAmount > resource.capacity then
            currentAmount = resource.capacity
        end
    end

    if (shouldUpdateServer(resource)) then
        lastSendToServer = currentAmount
        updateServerWithLatestValues()
    end

    local percentage = 100 * currentAmount / resource.capacity
    setEnergyBarProgress(percentage)
end

addEvent("resourceInUseFromServer", true) -- (resourceKey, burnRate)
addEventHandler("resourceInUseFromServer", getRootElement(), function(resourceKey, burnRate, minBurn)
    outputConsole("Burning "..resourceKey.." with rate "..burnRate)
    
    if burnRate == 0 then
        if minBurn then
            currentAmount = math.max(currentAmount - minBurn, 0)
        end
    else
        burningRate = burnRate
        isBurning = true
    end
    updateServerWithLatestValues()
end)

addEvent("resourceNotInUseFromServer", true) -- (resourceKey, totalAmount)
addEventHandler("resourceNotInUseFromServer", getRootElement(), function(resourceKey, totalAmount)
    outputConsole("Not burning "..resourceKey)
    isBurning = false
    burningRate = 0
    updateServerWithLatestValues()
end)

setEnergyBarProgress(0)
setTimer(fillBarPeriodically, timerDiff, 0)