local lastTargetPosKey = "lastTargetPosKey"

addEvent("powerStateChangedClient", true)
addEvent("goldCarrierCleared", true)
addEvent("makeGhostFromServer", true)
addEvent("unmakeGhostFromServer", true)

function outputLog(message)
    outputConsole(message)
end

function getLastTarget(player)
    local lastTarget = getElementData(player, lastTargetPosKey)
    if not lastTarget then
        outputConsole("No last target found")
        return nil
    end
    return lastTarget
end