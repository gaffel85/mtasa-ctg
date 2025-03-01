local shieldedPlayers = {}
local shieldTimers = {}

function isShielded(player)
    return shieldedPlayers[player] == true
end

function addShieldedPlayer(player)
    --outputChatBox('--Adding shield to player '..inspect(otherPlayer))
    shieldedPlayers[player] = true
end

function removeShieldedPlayer(player)
    shieldedPlayers[player] = nil
    local oldShieldTimer = shieldTimers[player]
    if oldShieldTimer then
        killTimer(oldShieldTimer)
        shieldTimers[player] = nil
    end
end

function collisisionWithPlayer(otherPlayer, damage)
    --outputChatBox('Collision with player '..inspect(otherPlayer).. ' 1 '..inspect(client).. ' 2 '..inspect(source).. ' 3 '..inspect(sourceRoot))
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
        --outputChatBox('Gold carrier was shielded player '..inspect(goldCarrier))
        local oldShieldTimer = shieldTimers[goldCarrier]
        if not oldShieldTimer then
            shieldTimers[goldCarrier] = setTimer(function()
                --outputChatBox('Remove shield by timer  for gold carrier '..inspect(goldCarrier))
                removeShieldedPlayer(goldCarrier)
                triggerClientEvent(getRootElement(), "onShieldRemovedFromServer", resourceRoot, goldCarrier)
            end, 1000, 1)
        end
    else 
        --outputChatBox('No shield '..inspect(otherPlayer))
        changeGoldCarrier(notGoldCarrier)
    end
end
addEvent("onCollisionWithPlayer", true)
addEventHandler("onCollisionWithPlayer", getRootElement(), collisisionWithPlayer)