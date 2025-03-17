local shieldedPlayers = {}

function isShielded(player)
    return shieldedPlayers[player] ~= nil
end

function addShieldedPlayer(player, hits, duration)
    local oldVal = shieldedPlayers[player]
    if oldVal then
        if oldVal.hits > hits then
            return
        end
        local oldShieldTimer = oldVal.timer
        if oldShieldTimer then
            killTimer(oldShieldTimer)
        end
    end

    shieldedPlayers[player] = { hits = hits, duration = duration }
    triggerClientEvent(getRootElement(), "onShieldAddedFromServer", getRootElement(), player, 100000)
    if (hits <= 0) then
       descreaseShield(player)
    end
end

function removeShieldedPlayer(player)
    local oldShieldTimer = shieldedPlayers[player] and shieldedPlayers[player].timer
    if oldShieldTimer then
        killTimer(oldShieldTimer)
    end
    shieldedPlayers[player] = nil
    triggerClientEvent(getRootElement(), "onShieldRemovedFromServer", resourceRoot, player)
end

function increaseHits(player)
    if shieldedPlayers[player] then
        local newVal = shieldedPlayers[player].hits - 1
        shieldedPlayers[player].hits = newVal
        return newVal
    end
    return 0
end

function descreaseShield(player)
    local newHits = increaseHits(player)
    if newHits <= 0 then
        local oldShieldTimer = shieldedPlayers[player].timer
        if not oldShieldTimer then
            local duration = shieldedPlayers[player].duration
            triggerClientEvent(getRootElement(), "onShieldAddedFromServer", getRootElement(), player, duration)
            shieldedPlayers[player].timer = setTimer(function()
                removeShieldedPlayer(player)
                triggerClientEvent(getRootElement(), "onShieldRemovedFromServer", resourceRoot, player)
            end, duration * 1000, 1)
        end
    end
end

function collisisionWithPlayer(otherPlayer, damage)
    local goldCarrier = getGoldCarrier()
    local notGoldCarrier = nil
    if otherPlayer == goldCarrier then
        notGoldCarrier = client
    elseif client == goldCarrier then
        notGoldCarrier = otherPlayer
    end

    if not notGoldCarrier then
        return
    end

    if isShielded(goldCarrier) then
        descreaseShield(goldCarrier)
    else 
        changeGoldCarrier(notGoldCarrier)
    end
end
addEvent("onCollisionWithPlayer", true)
addEventHandler("onCollisionWithPlayer", getRootElement(), collisisionWithPlayer)