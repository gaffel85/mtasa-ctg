local powerBoxes = {}
local xDiff = 0.1

addEvent("boosterCooldownTick", true)
addEvent("boosterDurationTick", true)
addEvent("powerupSetCooldownClient", true)
addEvent("powerupSetReadyClient", true)
addEvent("powerupSetDisabledClient", true)
addEvent("powerupSetDurationClient", true)

function createPowerUpBox(index)
    local posX = 0.7 - xDiff * index
    local powerwindow = guiCreateWindow(posX, 0.92, 0.08, 0.06, "Power Up", true)
    guiWindowSetSizable(powerwindow, false)
    guiSetAlpha(powerwindow, 1.00)
    guiSetProperty(powerwindow, "CaptionColour", "FEFFFFFF")

    local powercooldown = guiCreateProgressBar(54, 45, 85, 12, false, powerwindow)
    guiSetAlpha(powercooldown, 0.88)
    guiProgressBarSetProgress(powercooldown, 42)
    local powerbutton = guiCreateButton(10, 21, 36, 36, "lctrl", false, powerwindow)
    guiSetFont(powerbutton, "clear-normal")
    guiSetProperty(powerbutton, "NormalTextColour", "FEFFFFFF")
    local charge1 = guiCreateRadioButton(56, 26, 14, 15, "", false, powerwindow)
    local charge2 = guiCreateRadioButton(74, 26, 14, 15, "", false, powerwindow)
    local charge3 = guiCreateRadioButton(92, 26, 14, 15, "", false, powerwindow)
    local charge4 = guiCreateRadioButton(110, 26, 14, 15, "", false, powerwindow)
    local charge5 = guiCreateRadioButton(128, 26, 14, 15, "", false, powerwindow)
    local status = guiCreateLabel(53, 26, 88, 19, "Status update", false, powerwindow)
    guiSetVisible(status, false)
    --guiRadioButtonSetSelected(charge3, true)
    return {
        window = powerwindow,
        button = powerbutton,
        progress = powercooldown,
        charges = {charge1, charge2, charge3, charge4, charge5},
    }
end
--addEventHandler("onClientResourceStart", resourceRoot, createPowerUpBox)

for i = 1, 10 do
    powerBoxes[i] = nil
end

function getOrCreatePowerBox(index, name, key)
	local powerBox = powerBoxes[index]
	if ( powerBox ) then
		if ( source ~= localPlayer) then
			guiSetVisible(powerBox.window, false)
		else
			guiSetVisible(powerBox.window, true)
		end
	end

	if (powerBox == nil) then
        powerBox = createPowerUpBox(index)
		powerBoxes[index] = powerBox
	end

	return powerBox
end

function tickPowerUpCooldown(timeLeft, totalTime, index, name, key, enabled)
    --outputChatBox("tickPowerUpCooldown")
	local powerBox = getOrCreatePowerBox(index, name, key)
    guiSetVisible(powerBox.window, true)
	guiSetText(powerBox.button, key)
    guiSetText(powerBox.window, name)

	local progress = 100 * (totalTime - timeLeft)/totalTime
	if ( progress < 99.5 ) then
		guiSetAlpha ( powerBox.window,0.5 )
	else 
        guiSetAlpha ( powerBox.button, 1 )
		guiSetAlpha ( powerBox.window, 1 )
	end
	guiProgressBarSetProgress(powerBox.progress, progress)
end
addEventHandler("boosterCooldownTick", getRootElement(), tickPowerUpCooldown)

function tickPowerUpDuration(timeLeft, totalTime, index, name, key, enabled)
	local powerBox = getOrCreatePowerBox(index, name, key)
	--local boosterLabel = boosterLabels[index]

	local progress = 100 - (100 * (totalTime - timeLeft)/totalTime)
	-- guiLabelSetColor ( boosterLabel, 77, 77, 77 )
    guiSetAlpha ( powerBox.button, 0.5 )
	guiProgressBarSetProgress(powerBox.progress, progress)
end
addEventHandler("boosterDurationTick", getRootElement(), tickPowerUpDuration)