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
        defaultText = "Super car"
    },
    offroad = {
        button = nil,
        label = nil,
        key = "offroad",
        lastState = nil,
        lastTimeLeft = nil,
        defaultText = "Offroad"
    },
    airplane = {
        button = nil,
        label = nil,
        key = "airplane",
        lastState = nil,
        lastTimeLeft = nil,
        defaultText = "Airplane"
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
    outputChatBox("showVehicleProgressBar: "..inspect(shouldShow))
    DGS:dgsSetVisible(progressBar, shouldShow)
    DGS:dgsSetVisible(vehiclesUi.superCar.button, not shouldShow)
    DGS:dgsSetVisible(vehiclesUi.offroad.button, not shouldShow)
    DGS:dgsSetVisible(vehiclesUi.airplane.button, not shouldShow)
end

function setAlphaForLabels(alpha)
    DGS:dgsSetAlpha(vehiclesUi.superCar.label, alpha)
    DGS:dgsSetAlpha(vehiclesUi.offroad.label, alpha)
    DGS:dgsSetAlpha(vehiclesUi.airplane.label, alpha)
end

function setVehicleProgressTimer(timeLeft, backwards)
    killVehicleTimerForWindow()
    if backwards then
        DGS:dgsProgressBarSetProgress(progressBar, 100)
    else
        DGS:dgsProgressBarSetProgress(progressBar, 0)
    end
    local progressSteps = 1
    local steps = 100 / progressSteps
    local timeDelta = 1000 * timeLeft / steps
 
    if backwards then
        progressSteps = -progressSteps
    end
    
    --outputChatBox("timeLef: "..inspect(timeLeft).." steps: "..steps.." progressSteps: "..progressSteps.." timeDelta: "..timeDelta)
    timer = setTimer(function()
        local oldProgress = DGS:dgsProgressBarGetProgress(progressBar)
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

local function createButton(x, y, text, vehicleWindow)
    local rndRect = DGS:dgsCreateRoundRect(0.3, true ,tocolor(90,90,90,255))
    local button = DGS:dgsCreateButton(x, y, 0.21, yVerticalHeight, text, true, vehicleWindow)
    DGS:dgsSetProperty(button, "image", rndRect)
    return button
end

local function createLabel(x, y, text, vehicleWindow)
    local label = DGS:dgsCreateLabel(x, y, 0.88, yVerticalHeight, text, true, vehicleWindow)
    DGS:dgsLabelSetVerticalAlign(label, "center")
    return label
end


local function createVehicleWindow()
    vehicleWindow = DGS:dgsCreateWindow(0.02, 0.5, 0.1, 0.12, "Swtich Vehicle", true)
    DGS:dgsSetProperty(vehicleWindow, "closeButtonEnabled", false)
    DGS:dgsSetProperty(vehicleWindow, "titleColor", tocolor(255, 255, 60, 255))
    progressBar = DGS:dgsCreateProgressBar(xPadding, yPadding, 0.26, 0.71, true, vehicleWindow)
    DGS:dgsProgressBarSetStyle(progressBar,"normal-vertical")
    DGS:dgsSetProperty(progressBar, "barColor", tocolor(255, 255, 60, 255))
    
    local y = yPadding
    vehiclesUi.superCar.button = createButton(xPadding, y, "1", vehicleWindow)
    vehiclesUi.superCar.label = createLabel(0.37, y, "Super car", vehicleWindow)
    DGS:dgsSetProperty(vehiclesUi.superCar.label, "verticalAlign", "center")
    
    y = y + yVerticalHeight + yElementPadding
    vehiclesUi.offroad.button = createButton(xPadding, y, "2", vehicleWindow)
    vehiclesUi.offroad.label = createLabel(0.37, y, "Offroad", vehicleWindow)
    DGS:dgsSetProperty(vehiclesUi.offroad.label, "verticalAlign", "center")
    
    y = y + yVerticalHeight + yElementPadding
    vehiclesUi.airplane.button = createButton(xPadding, y, "3", vehicleWindow)
    vehiclesUi.airplane.label = createLabel(0.37, y, "Airplane", vehicleWindow)
    DGS:dgsSetProperty(vehiclesUi.airplane.label, "verticalAlign", "center")

    DGS:dgsSetVisible(progressBar, false)
    return vehicleWindow
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
            outputConsole("State: "..stateStringName(state).." Priority: "..prio)
            if prio > highestPrio then
                highestPrio = prio
                highestPrioUi = vehicleUi
            end
        end
    end
    return highestPrioUi
end

function stateStringName(state)
    for key, value in pairs(stateEnum) do
        if value == state then
            return key
        end
    end
    return ""
end

function inspectState()
    local printableState = {
        superCar = stateStringName(vehiclesUi.superCar.lastState).."("..inspect(vehiclesUi.superCar.lastState)..")",
        offroad = stateStringName(vehiclesUi.offroad.lastState).."("..inspect(vehiclesUi.offroad.lastState)..")",
        airplane = stateStringName(vehiclesUi.airplane.lastState).."("..inspect(vehiclesUi.airplane.lastState)..")",
    }
    outputConsole(inspect(printableState))
end

addEvent("powerStateChangedClient", true)
addEventHandler("powerStateChangedClient", getRootElement(), function (state, oldState, powerKey, message, bindKey, charges, totalCharges, timeLeft)
    --outputChatBox("Power state changed: "..state.." for "..powerKey)
    getVehicleWindow()

    local vehicleUi = vehiclesUi[powerKey]
    if not vehicleUi then
        return
    end
    vehicleUi.lastState = state
    vehicleUi.lastTimeLeft = timeLeft

    local combinedUi = getHighestPrioStateFromAll()
    if combinedUi then
        outputConsole("Combined state: "..stateStringName(combinedUi.lastState)..'('..inspect(combinedUi)..')')
    end

    if combinedUi and combinedUi.lastState == stateEnum.COOLDOWN then
        showVehicleProgressBar(true)
        setAlphaForLabels(0.5)
        setVehicleProgressTimer(combinedUi.lastTimeLeft, false)
    elseif combinedUi and combinedUi.lastState == stateEnum.IN_USE then
        showVehicleProgressBar(true)
        setAlphaForLabels(0.3)
        DGS:dgsSetAlpha(combinedUi.label, 1.0)
        setVehicleProgressTimer(combinedUi.lastTimeLeft, true)
    else
        setAlphaForLabels(1.0)
        showVehicleProgressBar(false)
        killVehicleTimerForWindow()
    end

    if state == stateEnum.OUT_OF_CHARGES then
        DGS:dgsSetText(vehicleUi.label, "Out of charges")
        DGS:dgsSetAlpha(vehicleUi.label, 0.5)
    elseif state == stateEnum.PAUSED then
        DGS:dgsSetText(vehicleUi.label, "Disabled when leading")
        DGS:dgsSetAlpha(vehicleUi.label, 0.5)
    elseif state == stateEnum.WAITING then
        DGS:dgsSetText(vehicleUi.label, "Not ready")
        DGS:dgsSetAlpha(vehicleUi.label, 0.5)
    elseif state == stateEnum.READY then
        DGS:dgsSetText(vehicleUi.label, vehicleUi.defaultText)
        DGS:dgsSetAlpha(vehicleUi.label, 1.0)
    end
end)



getVehicleWindow()