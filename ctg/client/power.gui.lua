local powerBoxes = {}
local timers = {}
local xDiff = 0.12
local keyOrder = { "lctrl", "z", "x", "c" }
local stateEnum = {
	READY = 1,
	COOLDOWN = 2,
	IN_USE = 3,
	OUT_OF_CHARGES = 4,
	PAUSED = 5,
	WAITING = 6
}

function addPowerUp(powerUp)
    -- Dummy method to catch shared powers
    outputServerLog("Power up added: "..powerUp.key)
end

local function getKeyIndex(key) 
    for i, k in ipairs(keyOrder) do
        if (k == string.lower(key)) then
            return i
        end
    end
    return 0
end

addEvent("powerupStateChangedClient", true)

function createPowerUpBox(index)
    local posX = 0.7 - xDiff * index
    local powerwindow = guiCreateWindow(posX, 0.92, 0.1, 0.06, "Power Up", true)
    guiWindowSetSizable(powerwindow, false)
    guiSetAlpha(powerwindow, 1.00)
    guiSetProperty(powerwindow, "CaptionColour", "FEFFFFFF")

    local powercooldown = guiCreateProgressBar(0, 0.3, 1, 1, true, powerwindow)
    guiSetAlpha(powercooldown, 0.88)
    guiProgressBarSetProgress(powercooldown, 42)
    local powerbutton = guiCreateButton(0.3, 0.3, 0.4, 0.9, "lctrl", true, powerwindow)
    guiSetFont(powerbutton, "clear-normal")
    guiSetProperty(powerbutton, "NormalTextColour", "FEFFFFFF")
    
    -- loop over cols and ropws for charges, 2 rows and 3 cols
    local charges = {}
    for i = 1, 5 do
        local row = math.floor((i - 1) / 3)
        local col = (i - 1) % 3
        local charge = guiCreateRadioButton(0.72 + col * 0.08, 0.37 + row * 0.2, 0.1, 0.18, "", true, powerwindow)
        guiSetVisible(charge, false)
        table.insert(charges, charge)
    end

    --local charge1 = guiCreateRadioButton(56, 26, 14, 15, "", false, powerwindow)
    --local charge2 = guiCreateRadioButton(74, 26, 14, 15, "", false, powerwindow)
    --local charge3 = guiCreateRadioButton(92, 26, 14, 15, "", false, powerwindow)
    --local charge4 = guiCreateRadioButton(110, 26, 14, 15, "", false, powerwindow)
    --local charge5 = guiCreateRadioButton(128, 26, 14, 15, "", false, powerwindow)
    local status = guiCreateLabel(0.05, 0.3, 0.9, 0.7, "Status update", true, powerwindow)
    guiLabelSetHorizontalAlign ( status, "center" )
    guiLabelSetVerticalAlign ( status, "center" )

    guiSetVisible(status, false)
    --guiRadioButtonSetSelected(charge3, true)
    return {
        window = powerwindow,
        button = powerbutton,
        progress = powercooldown,
        charges = charges,
        status = status
    }
end
--addEventHandler("onClientResourceStart", resourceRoot, createPowerUpBox)

function getOrCreatePowerBox(bindKey)
	local powerBox = powerBoxes[bindKey]
	if powerBox then
		if ( source ~= localPlayer) then
			guiSetVisible(powerBox.window, false)
		else
			guiSetVisible(powerBox.window, true)
		end
	end

	if (powerBox == nil) then
        local index = getKeyIndex(bindKey)
        powerBox = createPowerUpBox(index)
		powerBoxes[bindKey] = powerBox
	end

	return powerBox
end

local function addTimerForKey(timer, bindKey)
    local timerArray = timers[bindKey]
    if not timerArray then
        timerArray = {}
        timers[bindKey] = timerArray
    end
    table.insert(timerArray, timer)
end

local function killTimersForKey(bindKey)
    local timerArray = timers[bindKey]
    if timerArray then
        for i, timer in ipairs(timerArray) do
            if isTimer(timer) then
                killTimer(timer)
            end
        end
    end
    timers[bindKey] = {}
end

function setProgressTimer(powerBox, bindKey, timeLeft, backwards)
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
    addTimerForKey(setTimer(function()
        local oldProgress = guiProgressBarGetProgress(powerBox.progress)
        local newProgress = oldProgress + progressSteps
        --outputChatBox("oldProgress: "..oldProgress.." newProgress: "..newProgress)
        guiProgressBarSetProgress(powerBox.progress, newProgress)
    end, timeDelta, steps), bindKey)
end

local function setStatus(powerBoxStatusField, message)
    if message then
        guiSetText(powerBoxStatusField, message)
        guiSetVisible(powerBoxStatusField, true)
    else
        guiSetVisible(powerBoxStatusField, false)
    end
end

-- triggerClientEvent(player, "powerupStateChangedClient", player, stateType, oldState, powerUp.name, stateMessage, config.bindKey, state.charges, timeLeft(state))
addEventHandler("powerupStateChangedClient", getRootElement(), function (state, oldState, name, message, bindKey, charges, totalCharges, timeLeft)
    local powerBox = getOrCreatePowerBox(bindKey)
    killTimersForKey(bindKey)

    guiSetVisible(powerBox.window, true)
	guiSetText(powerBox.button, bindKey)
    guiSetText(powerBox.window, name)

    guiSetVisible(powerBox.button, false)
    guiSetVisible(powerBox.progress, false)
    guiSetVisible(powerBox.status, false)

    guiSetAlpha ( powerBox.button, 1 )
    guiSetAlpha ( powerBox.window, 1 )


    -- hide charges
    for i, charge in ipairs(powerBox.charges) do
        guiSetVisible(charge, false)
    end

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

        if totalCharges > 0 then
            for i, charge in ipairs(powerBox.charges) do
                --outputChatBox("charge index: "..inspect(i).." charges: "..inspect(charges).." totalCharges: "..inspect(totalCharges))
                guiRadioButtonSetSelected(charge, false)
                if i <= totalCharges then
                    guiSetVisible(charge, true)
                    if i <= charges then
                        guiSetAlpha(charge, 1)
                    else
                        guiSetAlpha(charge, 0.5)
                    end
                else
                    guiSetVisible(charge, false)
                end
            end
        end
    end
end)