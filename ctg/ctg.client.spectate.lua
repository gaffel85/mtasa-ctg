local alivePlayers = {}
local currentSpectateeName = nil

addEvent("playerDied", true)
addEvent("newRound", true)
addEvent("startSpectating", true)

function getCurrentIndex()
    if ( currentSpectatee == nil ) then
        return 1
    end

    local index = 1
    for i,player in ipairs(alivePlayers) do          -- find out what index the local player has in the list
        if getPlayerName ( player ) == currentSpectateeName then
            index = i
            break
        end
    end

    return index
end

function spectatePrevious()
    local index = getCurrentIndex()
    if index == 1 then
        index = #alivePlayers
    else
        index = index - 1
    end
    currentSpectateeName = getPlayerName ( alivePlayers[index] )
    setCameraTarget(alivePlayers[index])
end

function spectateNext()
     local index = getCurrentIndex()
     if index == #alivePlayers then
         index = 1
     else
         index = index + 1
     end
     currentSpectateeName = getPlayerName ( alivePlayers[index] )
     setCameraTarget(alivePlayers[index])
end

function onPlayerDied(allAlivePlayers)
    alivePlayers = allAlivePlayers
end
addEventHandler("playerDied", getRootElement(), onPlayerDied)

function onNewRound()
    alivePlayers = getElementsByType("player")
    unbindKey("arrow_l", "down", spectatePrevious)
    unbindKey("arrow_r", "down", spectateNext)
end
addEventHandler("newRound", getRootElement(), onNewRound)

function onStartSpectating()
    if ( source == localPlayer and #alivePlayers > 0) then
        bindKey("arrow_l", "down", spectatePrevious)
        bindKey("arrow_r", "down", spectateNext)
        spectateNext()
    end
end
addEventHandler("startSpectating", getRootElement(), onStartSpectating)