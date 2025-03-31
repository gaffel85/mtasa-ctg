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

addEvent("energyAmountChangedFromClient", true)
addEventHandler("energyAmountChangedFromClient", resourceRoot, function(key, amount)
    addAmount(source, key, amount)
    outputServerLog("energyAmountChangedFromClient"..inspect(source).." "..key.." "..amount)
end)

function resetResouceAmount(player, key)
    local resourceState = getResourceState(player, key)
    if not resourceState then
        outputServerLog("Could not get resource state in resetResourceAmount")
        return
    end
    resourceState.amount = 0
end

function initResourceState(player, resource)
    local playerState = resourceState[player]
    if not playerState then
        playerState = {}
        resourceState[player] = playerState
    end
    local resourceState = {
        amount = resource.initialCapacity,
    }
    playerState[resource.key] = resourceState
    return resourceState
end

addEventHandler("onResourceStart", resourceRoot, function()
    resourceState = {}
    addResource(energyResource)
end)

addEventHandler("onPlayerJoin", getRootElement(), function()
    for i, resource in ipairs(resources) do
        initResourceState(source, resource)
    end
end)

setTimer(function()
    for i, player in ipairs(getElementsByType("player")) do
        loopOverPowersForPlayer2(player, function(player, powerUp, powerUpState, powerConfig)
            if powerUp.state ~= getStateEnum().IN_USE then
                --addAmount(player, powerUp.resourceKey, 30)
            end
        end)
    end
end, 10000000000, 0)


