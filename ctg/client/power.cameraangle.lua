addEvent("setCinematicCameraAngle", true)

local oldCameraMode = nil
local forceTimer = nil

function setCinematicCameraAngle()
    local veh, ped = getCameraViewMode()
    oldCameraMode = veh
    setCameraViewMode(5)

    forceTimer = setTimer(function()
        local veh, ped = getCameraViewMode()
        if veh ~= 5 then
            setCameraViewMode(5)
        end
    end, 500, 0)
end
addEventHandler("setCinematicCameraAngle", getRootElement(), setCinematicCameraAngle)

function resetCameraAngle()
    if forceTimer then
        killTimer(forceTimer)
        forceTimer = nil
    end
    if oldCameraMode == nil then
        return
    end
    setCameraViewMode(oldCameraMode)
end
addEventHandler("resetCameraAngle", getRootElement(), resetCameraAngle)