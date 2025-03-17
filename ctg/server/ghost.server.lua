function setPlayerGhost(player)
    return setElementData(player, "isGhost", true)
end

function makePlayerGhost(plauer, duration, safeCheck)
    setPlayerGhost(player)
    triggerClientEvent("makeGhostFromServer", getRootElement())
end

registerBindFunctions(function()
    bindKey(player, "g", "down", makePlayerGhost)
end, function()
    unbindKey(player, "g", "down", makePlayerGhost)
end)

