local powerBoxes = {}
local xDiff = 0.1

function createPowerUpBox(index)
    local posX = 0.9 - xDiff * index
    local powerwindow = guiCreateWindow(posX, 0.90, 0.08, 0.09, "Power Up", true)
    guiWindowSetSizable(powerwindow, false)
    guiSetAlpha(powerwindow, 1.00)
    guiSetProperty(powerwindow, "CaptionColour", "FEFFFFFF")

    local powercooldown = guiCreateProgressBar(10, 83, 129, 16, false, powerwindow)
    guiSetAlpha(powercooldown, 0.88)
    guiProgressBarSetProgress(powercooldown, 42)
    local powerbutton = guiCreateButton(48, 31, 62, 42, "key", false, powerwindow)
    guiSetFont(powerbutton, "clear-normal")
    guiSetProperty(powerbutton, "NormalTextColour", "FEFFFFFF")
    local charge1 = guiCreateRadioButton(131, 21, 15, 15, "", false, powerwindow)
    local charge2 = guiCreateRadioButton(131, 41, 15, 15, "", false, powerwindow)
    local charge3 = guiCreateRadioButton(132, 61, 15, 15, "", false, powerwindow)
    --guiRadioButtonSetSelected(charge3, true)
    return {
        window = powerwindow,
        button = powerbutton,
        progress = powercooldown,
        charges = {charge1, charge2, charge3}
    }
end
--addEventHandler("onClientResourceStart", resourceRoot, createPowerUpBox)

for i = 1, 10 do
    powerBoxes[i] = nil
end

function getOrCreatePowerBox(index, name, key)
	local powerBox = powerBoxes[index]
    outputChatBox("Found powerBox: "..inspect(powerBox))
	if ( powerBox ) then
		if ( source ~= localPlayer) then
            outputChatBox("Plauer false powerBox: "..inspect(source).." "..inspect(localPlayer))
			guiSetVisible(powerBox.window, false)
		else
            outputChatBox("Plauer true powerBox: "..inspect(source).." "..inspect(localPlayer))
			guiSetVisible(powerBox.window, true)
		end
	end

	if (powerBox == nil) then
        powerBox = createPowerUpBox(index)
		powerBoxes[index] = powerBox
	end

    outputChatBox("Returning powerBox: "..inspect(powerBox))

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
addEvent("boosterCooldownTick", true)
addEventHandler("boosterCooldownTick", getRootElement(), tickPowerUpCooldown)

function tickPowerUpDuration(timeLeft, totalTime, index, name, key, enabled)
	local powerBox = getOrCreatePowerBox(index, name, key)
	--local boosterLabel = boosterLabels[index]

	local progress = 100 - (100 * (totalTime - timeLeft)/totalTime)
	-- guiLabelSetColor ( boosterLabel, 77, 77, 77 )
    guiSetAlpha ( powerBox.button, 0.5 )
	guiProgressBarSetProgress(powerBox.progress, progress)
end
addEvent("boosterDurationTick", true)
addEventHandler("boosterDurationTick", getRootElement(), tickPowerUpDuration)