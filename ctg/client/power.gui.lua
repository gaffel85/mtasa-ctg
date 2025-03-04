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
    
    local charge1 = guiCreateRadioButton(56, 26, 14, 15, "", false, powerwindow)
    local charge2 = guiCreateRadioButton(74, 26, 14, 15, "", false, powerwindow)
    local charge3 = guiCreateRadioButton(92, 26, 14, 15, "", false, powerwindow)
    local charge4 = guiCreateRadioButton(110, 26, 14, 15, "", false, powerwindow)
    local charge5 = guiCreateRadioButton(128, 26, 14, 15, "", false, powerwindow)
    local status = guiCreateLabel(53, 26, 88, 19, "Status update", false, powerwindow)

    guiSetVisible(charge1, false)
    guiSetVisible(charge2, false)
    guiSetVisible(charge3, false)
    guiSetVisible(charge4, false)
    guiSetVisible(charge5, false)
    guiSetVisible(status, false)
    --guiRadioButtonSetSelected(charge3, true)
    return {
        window = powerwindow,
        button = powerbutton,
        progress = powercooldown,
        charges = {charge1, charge2, charge3, charge4, charge5},
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

function setProgressTimer(powerBox, bindKey, timeLeft)
    guiProgressBarSetProgress(powerBox.progress, 0)
    local steps = timeLeft * 100
    local progressSteps = 100 / steps
    addTimerForKey(setTimer(function()
        local oldProgress = guiProgressBarGetProgress
        guiProgressBarSetProgress(powerBox.progress, oldProgress + progressSteps)
    end, 10, steps), bindKey)
end

-- triggerClientEvent(player, "powerupStateChangedClient", player, stateType, oldState, powerUp.name, stateMessage, config.bindKey, state.charges, timeLeft(state))
addEventHandler("powerupStateChangedClient", getRootElement(), function (state, oldState, name, message, bindKey, charges, totalCharges, timeLeft)
    local powerBox = getOrCreatePowerBox(bindKey)
    killTimersForKey(bindKey)

    guiSetVisible(powerBox.window, true)
	guiSetText(powerBox.button, key)
    guiSetText(powerBox.window, name)

    guiSetVisible(powerBox.button, false)
    guiSetVisible(powerBox.progress, false)
    guiSetVisible(powerBox.status, false)
    -- hide charges
    for i, charge in ipairs(powerBox.charges) do
        guiSetVisible(charge, false)
    end

    if state == stateEnum.COOLDOWN then
        guiSetVisible(powerBox.progress, true)
		guiSetAlpha ( powerBox.window,0.5 )
        setProgressTimer(powerBox, bindKey, timeLeft)
    elseif state == stateEnum.IN_USE then
        guiSetVisible(powerBox.progress, true)
        setProgressTimer(powerBox, bindKey, timeLeft)
    elseif state == stateEnum.OUT_OF_CHARGES then
        guiSetAlpha ( powerBox.button, 0.5 )
        guiSetVisible(powerBox.status, true)
        guiSetText(powerBox.status, message)
    elseif state == stateEnum.PAUSED then
        guiSetVisible(powerBox.status, true)
        guiSetAlpha ( powerBox.button, 0.5 )
        guiSetText(powerBox.status, message)
    elseif state == stateEnum.WAITING then
        guiSetVisible(powerBox.status, true)
        guiSetAlpha ( powerBox.button, 0.5 )
        guiSetText(powerBox.status, message)
    elseif state == stateEnum.READY then
        guiSetVisible(powerBox.button, true)
        guiSetAlpha ( powerBox.button, 1 )
        guiSetAlpha ( powerBox.window, 1 )

        if totalCharges > 0 then
            for i, charge in ipairs(powerBox.charges) do
                if i <= totalCharges then
                    guiSetVisible(charge, true)
                    if i <= charges then
                        guiRadioButtonSetSelected(charge, true)
                    else
                        guiRadioButtonSetSelected(charge, false)
                    end
                else
                    guiSetVisible(charge, false)
                end
            end
        end
    end
end)