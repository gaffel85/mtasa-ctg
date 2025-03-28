local resources = {}
local resourceState = {}

local nitroPowerUp = {
	key = "energy",
	name = "Energy",
	desc = "",
    type = "manual",
	capacity = 100,
    initialCapacity = 30,
}

function addResource(resource)
    table.insert(resources, resource)
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
        return
    end
    local resourceState = playerState[key]
    if not resourceState then
        resourceState = initResourceState(player, getResource(key))
    end
    outputServerLog("Resource "..key.." "..inspect(resourceState))
    return resourceState
end

function addAmount(player, key, amount)
    local resourceState = getResourceState(player, key)
    if not resourceState then
        outputServerLog("Could not get resource state in addAmount")
        return
    end
    resourceState.amount = resourceState.amount + amount
end

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
    addResource(nitroPowerUp)
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
                addAmount(player, resource.key, 30)
            end
        end)
    end
end, 5000, 0)


