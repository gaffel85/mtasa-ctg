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
        lastTimeLeft = nil,
    },
    offroad = {
        button = nil,
        label = nil,
        key = "offroad",
        lastState = nil,
        lastTimeLeft = nil,
    },
    airplane = {
        button = nil,
        label = nil,
        key = "airplane",
        lastState = nil,
        lastTimeLeft = nil,
    },
}
local stateEnum = {
	READY = 1,
	COOLDOWN = 2,
	IN_USE = 3,
	OUT_OF_CHARGES = 4,
	PAUSED = 5,
	WAITING = 6
}
local statePrio = {
    [stateEnum.READY] = 0,
    [stateEnum.COOLDOWN] = 1,
    [stateEnum.IN_USE] = 2,
    [stateEnum.OUT_OF_CHARGES] = 0,
    [stateEnum.PAUSED] = 0,
    [stateEnum.WAITING] = 0
}

function showVehicleProgressBar(shouldShow)
    DGS:dgsSetVisible(progressBar, shouldShow)
    DGS:dgsSetVisible(vehiclesUi.superCar.button, not shouldShow)
    DGS:dgsSetVisible(vehiclesUi.offroad.button, not shouldShow)
    DGS:dgsSetVisible(vehiclesUi.airplane.button, not shouldShow)
end

function setVehicleProgressTimer(timeLeft, backwards)
    if backwards then
        guiProgressBarSetProgress(powerBox.progress, 100)
    else
        guiProgressBarSetProgress(powerBox.progress, 0)
    end
    local progressSteps = 1
    local steps = 100 / progressSteps
    local timeDelta = 1000 * timeLeft / steps
 
    if backwards then
        progressSteps = -progressSteps
    end
    
    --outputChatBox("timeLef: "..inspect(timeLeft).." steps: "..steps.." progressSteps: "..progressSteps.." timeDelta: "..timeDelta)
    timer = setTimer(function()
        local oldProgress = DGS:dgsProgressBarSetProgress(progressBar)
        local newProgress = oldProgress + progressSteps
        --outputChatBox("oldProgress: "..oldProgress.." newProgress: "..newProgress)
        DGS:dgsProgressBarSetProgress(progressBar, newProgress)
    end, timeDelta, steps)
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

local xPadding = 0.08
local yPadding = 0.05
local yVerticalHeight = 0.21
local yElementPadding = 0.05
local function createVehicleWindow()
    vehicleWindow = DGS:dgsCreateWindow(0.02, 0.5, 0.1, 0.1, "Swtich Vehicle", true)
    DGS:dgsSetProperty(vehicleWindow, "closeButtonEnabled", false)
    DGS:dgsSetProperty(vehicleWindow, "titleColor", tocolor(255, 255, 60, 255))
    progressBar = DGS:dgsCreateProgressBar(xPadding, 0.20, 0.26, 0.71, true, vehicleWindow)
    DGS:dgsSetProperty(progressBar, "barColor", tocolor(255, 255, 60, 255))
    
    local y = yPadding
    vehiclesUi.superCar.button = DGS:dgsCreateButton(xPadding, y, 0.21, yVerticalHeight, "1", true, vehicleWindow)
    vehiclesUi.superCar.label = DGS:dgsCreateLabel(0.37, y, 0.88, yVerticalHeight, "Super car", true, vehicleWindow)
    DGS:dgsSetProperty(vehiclesUi.superCar.label, "verticalAlign", "center")
    
    y = y + yVerticalHeight + yElementPadding
    vehiclesUi.offroad.button = DGS:dgsCreateButton(xPadding, y, 0.21, yVerticalHeight, "2", true, vehicleWindow)
    vehiclesUi.offroad.label = DGS:dgsCreateLabel(0.37, y, 0.88, yVerticalHeight, "Offroad", true, vehicleWindow)
    DGS:dgsSetProperty(vehiclesUi.offroad.label, "verticalAlign", "center")
    
    y = y + yVerticalHeight + yElementPadding
    vehiclesUi.airplane.button = DGS:dgsCreateButton(xPadding, y, 0.21, yVerticalHeight, "3", true, vehicleWindow)
    vehiclesUi.airplane.label = DGS:dgsCreateLabel(0.37, y, 0.88, yVerticalHeight, "Airplane", true, vehicleWindow)
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

function getHighestPrioStateFromAll()
    local highestPrio = 0
    local highestPrioUi = nil
    for key, vehicleUi in pairs(vehiclesUi) do
        local state = vehicleUi.lastState
        if state then
            local prio = statePrio[state]
            if prio > highestPrio then
                highestPrio = prio
                highestPrioUi = vehicleUi
            end
        end
    end
    return highestPrio, highestPrioUi
end

addEventHandler("powerStateChangedClient", getRootElement(), function (state, oldState, powerKey, message, bindKey, charges, totalCharges, timeLeft)
    getVehicleWindow()
    killVehicleTimerForWindow()

    local vehicleUi = vehiclesUi[powerKey]
    if not vehicleUi then
        return
    end
    vehicleUi.lastState = state
    vehicleUi.lastTimeLeft = timeLeft

    local combinedState, combinedUi = getHighestPrioStateFromAll()

    if combinedState == stateEnum.COOLDOWN then
        showVehicleProgressBar(true)
        setVehicleProgressTimer(combinedUi.lastTimeLeft, false)
    elseif combinedState == stateEnum.IN_USE then
        showVehicleProgressBar(true)
        setVehicleProgressTimer(combinedUi.lastTimeLeft, true)
    else
        showVehicleProgressBar(false)
    end

    --[[
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
    ]]--
end)



getVehicleWindow()