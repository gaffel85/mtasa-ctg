local lastTargetPosKey = "lastTargetPosKey"

function outputLog(message)
    outputConsole(message)
end

function getLastTarget()
    local lastTarget = getElementData(resourceRoot, lastTargetPosKey)
    if not lastTarget then
        outputConsole("No last target found")
        return nil
    end
    return lastTarget
end