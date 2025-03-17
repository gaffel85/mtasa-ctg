local bindFunctions = {}
local unbindFunctions = {}

function registerBindFunctions(bindFunction, unbindFunction)
    table.insert(bindFunctions, bindFunction)
    table.insert(unbindFunctions, unbindFunction)
end

function bindOnJoin ( )
    for k, bindFunction in ipairs(bindFunctions) do
        bindFunction(source)
    end
end
addEventHandler("onPlayerJoin", getRootElement(), bindOnJoin)

function unbindUnQuit ( )
    for k, unbindFunction in ipairs(unbindFunctions) do
        unbindFunction(source)
    end
end
addEventHandler("onPlayerQuit", getRootElement(), unbindUnQuit)

function bindOnResourceStart()
    for k, player in ipairs(getElementsByType("player")) do
        for k, bindFunction in ipairs(bindFunctions) do
            bindFunction(player)
        end
    end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), bindOnResourceStart)

function unbindOnResourceStop()
    for k, player in ipairs(getElementsByType("player")) do
        for k, unbindFunction in ipairs(unbindFunctions) do
            unbindFunction(player)
        end
    end
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), unbindOnResourceStop)