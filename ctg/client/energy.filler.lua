DGS = exports.dgs --shorten the export function prefix

local energyBar = nil
local overchargeBar = nil
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

function createEnergyBar()
    energyBar = guiCreateProgressBar( 0.8, 0.5, 0.1, 0.04, true, nil ) --create the gui-progressbar
end

function create3dText()
    local x, y, z = getElementPosition(localPlayer)
    outputChatBox("x:"..x.." y:"..y.." z:"..z)
    local theMarker = createMarker ( x, y, z, "corona", 1.5, 255, 255, 0, 4 )
    local text = DGS:dgsCreate3DText(x, y, z, "DGS 3D Text Test", white)
    DGS:dgsSetProperty(text, "fadeDistance", 20)
    DGS:dgsSetProperty(text, "shadow", {1,1,tocolor(0,0,0,255),true})
    DGS:dgsSetProperty(text, "outline", {"out",1,tocolor(255,255,255,255)})
    DGS:dgs3DTextAttachToElement(text,theMarker,0,5,0)
end

setTimer(create3dText, 2000, 1)

function createOverChargeBar()
    -- overchargeBar = DGS:dgsCreateProgressBar(0.8, 0.55, 0.1, 0.04, true, nil)
    overchargeBar = DGS:dgsCreateProgressBar(0.8, 0.5, 0.3, 0.3, true, nil)
    DGS:dgsProgressBarSetStyle(overchargeBar,"ring-round",{
        isClockwise = true,
        rotation = 90,
        antiAliased = 0.005,
        radius = 0.2,
        thickness = 0.05
    })
end

function getEnergyBar()
    if energyBar == nil then
        createEnergyBar()
    end
    return energyBar, dsgEnergyBar
end

function getOverChargeBar()
    if overchargeBar == nil then
        createOverChargeBar()
    end
    return overchargeBar
end

function setEnergyBarProgress(percentage)   
    local energyBar = getEnergyBar()
    guiProgressBarSetProgress(energyBar, percentage)
end

function setOverChargeBarProgress(percentage)
    local overchargeBar = getOverChargeBar()
    DGS:dgsProgressBarSetProgress(overchargeBar, percentage)
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