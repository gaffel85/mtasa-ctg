local resources = {}
local resourceState = {}
local RESOURCES_KEY = "RESOURCES_KEY"

local energyResource = {
	key = "energy",
	name = "Energy",
	desc = "",
    type = "manual",
	capacity = 100,
    initialCapacity = 50,
}

local overchargeResource = {
    key = "overcharge",
    name = "Overcharge",
    desc = "",
    type = "manual",
    capacity = 100,
    initialCapacity = 0,
}

local vehicleTimeResource = {
    key = "vehicleTime",
    name = "Vehicle Time",
    desc = "",
    type = "time",
    capacity = 100,
    initialCapacity = 80,
    fillRate = 5,
}

function addResource(resource)
    table.insert(resources, resource)
    setElementData(resourceRoot, RESOURCES_KEY, resources)
end

function getResource(key)
    for i, resource in ipairs(resources) do
        if resource.key == key then
            return resource
        end
    end
end

function getResourceState(player, key)
    local playerState = resourceState[player]
    if not playerState then
        playerState = {}
        resourceState[player] = playerState
    end
    local resourceState = playerState[key]
    if not resourceState then
        -- outputServerLog("##### No state found, init new one"..inspect(player)..' '..key)
        resourceState = initResourceState(player, getResource(key))
    end
    return resourceState
end

function addAmount(player, key, amount)
    local resource = getResource(key)
    local resourceState = getResourceState(player, key)
    if not resourceState then
        outputServerLog("Could not get resource state in addAmount"..inspect(player).." "..key)
        return
    end
    local newAmount = resourceState.amount + amount
    if newAmount > resource.capacity then
        resourceState.amount = resource.capacity
    else
        resourceState.amount = newAmount
    end
end

function setAmount(player, key, amount)
    local resource = getResource(key)
    local resourceState = getResourceState(player, key)
    if not resourceState then
        outputServerLog("Could not get resource state in setAmount"..inspect(player).." "..key)
        return
    end
    -- outputServerLog("current amount "..resourceState.amount.. " setting to "..amount)
    local newAmount = amount
    if newAmount > resource.capacity then
        resourceState.amount = resource.capacity
    else
        resourceState.amount = newAmount
    end
end

addEvent("energyAmountChangedFromClient", true)
addEventHandler("energyAmountChangedFromClient", resourceRoot, function(key, amount, secondsUntilEnd, isBurning, burnRate, fillRate)
    -- outputServerLog("energyAmountChangedFromClient "..key.." "..amount.." "..secondsUntilEnd.." "..inspect(isBurning).." "..inspect(burnRate).." "..inspect(fillRate))
    setAmount(client, key, amount)
end)

function initResourceState(player, resource)
    local playerState = resourceState[player]
    if not playerState then
        playerState = {}
        resourceState[player] = playerState
    end
    local resourceState = {
        amount = resource.initialCapacity,
        lastChanged = getRealTime().timestamp,
    }
    playerState[resource.key] = resourceState
    return resourceState
end

addEventHandler("onResourceStart", resourceRoot, function()
    resourceState = {}
    addResource(energyResource)
    addResource(overchargeResource)
    addResource(vehicleTimeResource)
end)

addEventHandler("onPlayerJoin", getRootElement(), function()
    for i, resource in ipairs(resources) do
        initResourceState(source, resource)
    end
end)


