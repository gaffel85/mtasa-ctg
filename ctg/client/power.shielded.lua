

local shieldedPlayers = {}

function getShieldedPlayers()
    return shieldedPlayers
end

addEvent("onShieldAddedFromServer", true)
addEvent("onShieldRemovedFromServer", true)

function onShieldAdded(player, duration)
    shieldedPlayers[player] = duration
  -- outputChatBox('Shield added to player '..inspect(player))
end
addEventHandler("onShieldAddedFromServer", resourceRoot, onShieldAdded)

function onShieldRemoved(player)
    shieldedPlayers[player] = nil
  -- outputChatBox('Shield removed to player '..inspect(player))
end
addEventHandler("onShieldRemovedFromServer", resourceRoot, onShieldRemoved)