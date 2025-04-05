DGS = exports.dgs --shorten the export function prefix

local vehicleWindow = nil
local progressBar = nil
local timer = nil
local vehiclesUi = {
    superCar = {
        button = nil,
        label = nil,
        key = "superCar",
        lastState = nil,
        lastTime
    },
    offroad = {
        button = nil,
        label = nil,
        key = "offroad",
        lastState = nil,
    },
    airplane = {
        button = nil,
        label = nil,
        key = "airplane",
        lastState = nil,
    },
}

function showVehicleProgressBar()
    DGS:dgsSetVisible(progressBar, true)
    DGS:dgsSetVisible(vehiclesUi.superCar.button, false)
    DGS:dgsSetVisible(vehiclesUi.offroad.button, false)
    DGS:dgsSetVisible(vehiclesUi.airplane.button, false)
end

--[[

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        window = guiCreateWindow(0.01, 0.32, 0.06, 0.10, "Switch Vehicle", true)
        guiWindowSetSizable(window, false)

        button1 = guiCreateButton(0.08, 0.19, 0.21, 0.21, "1", true, window)
        vehicle1 = guiCreateLabel(0.37, 0.19, 0.88, 0.21, "Super car", true, window)
        guiLabelSetVerticalAlign(vehicle1, "center")
        button2 = guiCreateButton(0.08, 0.45, 0.21, 0.21, "2", true, window)
        vehicle2 = guiCreateLabel(0.37, 0.45, 0.88, 0.21, "Offroad", true, window)
        guiLabelSetVerticalAlign(vehicle2, "center")
        button3 = guiCreateButton(0.08, 0.75, 0.21, 0.21, "3", true, window)
        vehicle3 = guiCreateLabel(0.37, 0.75, 0.88, 0.21, "Airplane", true, window)
        guiLabelSetVerticalAlign(vehicle3, "center")
        progressBar = guiCreateEdit(0.08, 0.20, 0.26, 0.71, "", true, window)    
    end
)
]]--

local function createVehicleWindow()
    vehicleWindow = DGS:dgsCreateWindow(0.02, 0.5, 0.1, 0.1, "Swtich Vehicle", true)
    DGS:dgsSetProperty(vehicleWindow, "titleColor", tocolor(255, 255, 60, 255))
    progressBar = DGS:dgsCreateProgressBar(0.08, 0.20, 0.26, 0.71, true, vehicleWindow)
    DGS:dgsSetProperty(progressBar, "barColor", tocolor(255, 255, 60, 255))
    
    vehiclesUi.superCar.button = DGS:dgsCreateButton(0.08, 0.19, 0.21, 0.21, "1", true, vehicleWindow)
    vehiclesUi.superCar.label = DGS:dgsCreateLabel(0.37, 0.19, 0.88, 0.21, "Super car", true, vehicleWindow)
    DGS:dgsSetProperty(vehiclesUi.superCar.label, "verticalAlign", "center")
    
    vehiclesUi.offroad.button = DGS:dgsCreateButton(0.08, 0.45, 0.21, 0.21, "2", true, vehicleWindow)
    vehiclesUi.offroad.label = DGS:dgsCreateLabel(0.37, 0.45, 0.88, 0.21, "Offroad", true, vehicleWindow)
    DGS:dgsSetProperty(vehiclesUi.offroad.label, "verticalAlign", "center")
    
    vehiclesUi.airplane.button = DGS:dgsCreateButton(0.08, 0.75, 0.21, 0.21, "3", true, vehicleWindow)
    vehiclesUi.airplane.label = DGS:dgsCreateLabel(0.37, 0.75, 0.88, 0.21, "Airplane", true, vehicleWindow)
    DGS:dgsSetProperty(vehiclesUi.airplane.label, "verticalAlign", "center")

    DGS:dgsSetVisible(progressBar, false)
end

local function getVehicleWindow()
    if vehicleWindow == nil then
        vehicleWindow = createVehicleWindow()
    end
    return vehicleWindow
end

function killVehicleTimerForWindow()
    if timer and isTimer(timer) then
        killTimer(timer)
    end
end

addEventHandler("powerStateChangedClient", getRootElement(), function (state, oldState, powerKey, message, bindKey, charges, totalCharges, timeLeft)
    getVehicleWindow()
    killVehicleTimerForWindow()

    local vehicleUi = vehiclesUi[powerKey]
    if not vehicleUi then
        return
    end
    vehicleUi.lastState = state
    vehicleUi.lastMessage = message
    

    if state == stateEnum.COOLDOWN then
        guiSetVisible(powerBox.progress, true)
		guiSetAlpha ( powerBox.window,0.5 )
        setProgressTimer(powerBox, bindKey, timeLeft, false)
    elseif state == stateEnum.IN_USE then
        guiSetVisible(powerBox.progress, true)
        setProgressTimer(powerBox, bindKey, timeLeft, true)
    elseif state == stateEnum.OUT_OF_CHARGES then
        guiSetAlpha ( powerBox.window, 0.5 )
        guiSetVisible(powerBox.status, true)
        setStatus(powerBox.status, message)
    elseif state == stateEnum.PAUSED then
        guiSetVisible(powerBox.status, true)
        guiSetAlpha ( powerBox.window, 0.5 )
        setStatus(powerBox.status, message)
    elseif state == stateEnum.WAITING then
        guiSetVisible(powerBox.status, true)
        guiSetAlpha ( powerBox.window,0.5 )
        setStatus(powerBox.status, message)
    elseif state == stateEnum.READY then
        guiSetVisible(powerBox.button, true)
        guiSetAlpha ( powerBox.button, 1 )
        guiSetAlpha ( powerBox.window, 1 )
    end
end)



getVehicleWindow()