function setPlayerGhost(player)
    return setElementData(player, "isGhost", true)
end

function makePlayerGhost(player, duration, safeCheck)
    setPlayerGhost(player)
    triggerClientEvent("makeGhostFromServer", getRootElement())
end

registerBindFunctions(function(player)
    bindKey(player, "g", "down", makePlayerGhost, player, 30, true)
end, function(player)
    unbindKey(player, "g", "down", makePlayerGhost, player)
end)

