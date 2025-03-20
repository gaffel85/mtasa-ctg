function logDistanceToGround()
    local player = localPlayer
    local vehicle = getPedOccupiedVehicle(player)
    local x, y, z, x2, y2, z2 = getElementBoundingBox(vehicle)
    local radius = getElementRadius(vehicle)
    outputConsole("Hej "..inspect(radius).." "..inspect(x).." "..inspect(y).." "..inspect(z).." "..inspect(x2).." "..inspect(y2).." "..inspect(z2))
    --local x, y, z = getElementPosition(vehicle)
    --local distance = getElementDistanceFromCentreOfMassToBaseOfModel(vehicle)
    --local str = getVehicleName(vehicle).." : "..distance.."\n" 
    --local ground = getGroundPosition (x,y,z)
    --local groundDistance = z - ground
    --outputChatBox(""..distance.."      "..groundDistance)
end

function showHelp()
    local helpWindow = guiCreateWindow(0.01, 0.7, 0.1, 0.1, "Help", true)
    local helpLabel = guiCreateLabel(0.01, 0.1, 0.98, 0.9, "F1 = Join team 1\nF2 = Join team 2\nF3 = Choose power ups\nF4 = Vote for next vehicle", true, helpWindow)
    guiLabelSetHorizontalAlign(helpLabel, "center", true)
    guiLabelSetVerticalAlign(helpLabel, "center")
    guiSetVisible(helpWindow, true)
end

addEventHandler("onPlayerJoin", getRootElement(), function()
    outputChatBox("Starting timer")
    -- create small window to he left with for labels, one on each row.
    --[[]]--

    --setTimer(logDistanceToGround, 2000, 1000000)
end)

showHelp()

--outputChatBox("Loading help")
setTimer(logDistanceToGround, 2000, 3)

local currentVehicleId = 300
local vehicleSizeData = {}
function changeToNextVehicleAndGetBoundingBoxAndRadius()
    currentVehicleId = currentVehicleId + 1
    if currentVehicleId < 700 then
        outputChatBox("Done")
        outputConsole(inspect(vehicleSizeData))
        return
    end

    local player = localPlayer
    local vehicle = getPedOccupiedVehicle(player)
    if vehicle then 
        if setElementModel(vehicle, currentVehicleId) then
            local x, y, z, x2, y2, z2 = getElementBoundingBox(vehicle)
            local radius = getElementRadius(vehicle)
            vehicleSizeData[currentVehicleId] = {x = x, y = y, z = z, x2 = x2, y2 = y2, z2 = z2, radius = radius}
            outputConsole("Model for "..inspect(currentVehicleId).." "..inspect(radius).." "..inspect(x))
            setTimer(changeToNextVehicleAndGetBoundingBoxAndRadius, 2000, 1)
            return
        else
            outputChatBox("No model for"..currentVehicleId)
            changeToNextVehicleAndGetBoundingBoxAndRadius()
            return
        end
    end
    changeToNextVehicleAndGetBoundingBoxAndRadius()
    --local x, y, z = getElementPosition(vehicle)
    --local distance = getElementDistanceFromCentreOfMassToBaseOfModel(vehicle)
    --local str = getVehicleName(vehicle).." : "..distance.."\n" 
    --local ground = getGroundPosition (x,y,z)
    --local groundDistance = z - ground
    --outputChatBox(""..distance.."      "..groundDistance)
end

changeToNextVehicleAndGetBoundingBoxAndRadius()