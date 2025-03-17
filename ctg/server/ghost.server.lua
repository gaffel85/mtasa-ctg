local ghosts = {}

function unmakePlayerGhost(player)
    local record = ghosts[player]
    if record then
        if isTimer(record.timer) then
            killTimer(record.timer)
        end
        ghosts[player] = nil
        triggerClientEvent("unmakeGhostFromServer", getRootElement(), player)
    end
end

function makePlayerGhost(player, seconds, safeCheck)
    if ghosts[player] then
        unmakePlayerGhost(player)
    else
        ghosts[player] = {
            seconds = seconds,
            safeCheck = safeCheck,
            timer = setTimer(function()
                unmakePlayerGhost(player)
            end, seconds * 1000, 1)
        }
        triggerClientEvent("makeGhostFromServer", getRootElement(), player)
    end
end

registerBindFunctions(function(player)
    bindKey(player, "g", "down", makePlayerGhost, player, 5, true)
end, function(player)
    unbindKey(player, "g", "down", makePlayerGhost, player)
end)

