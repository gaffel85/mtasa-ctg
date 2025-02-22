/*local boosterBars = {}
local boosterLabels = {}
local barHeight = 0.05

for i = 1, 10 do
    boosterBars[i] = nil
	boosterLabels[i] = nil
end

function getOrCreateBoosterBar(index, name, key)
	local boosterBar = boosterBars[index]
	if ( boosterBar ) then
		if ( source ~= localPlayer) then
			guiSetVisible(boosterBar, false)
		else
			guiSetVisible(boosterBar, true)
		end
	end

	if (boosterBar == nil) then
		boosterBar = guiCreateProgressBar( 0.8, 0.35 + index * barHeight, 0.1, 0.03, true, nil ) --create the gui-progressbar
		boosterLabel = guiCreateLabel( 0, 0,1,1, name.." ("..key..")",true, boosterBar)
		boosterBars[index] = boosterBar
		boosterLabels[index] = boosterLabel
		guiLabelSetColor ( boosterLabel, 0, 128, 0 )
		guiLabelSetHorizontalAlign ( boosterLabel, "center" )
		guiLabelSetVerticalAlign ( boosterLabel, "center" )
		guiSetFont(boosterLabel, "default-bold-small")
	end

	return boosterBar
end

function tickBoosterCooldown(timeLeft, totalTime, index, name, key, enabled)
	local boosterBar = getOrCreateBoosterBar(index, name, key)
	local boosterLabel = boosterLabels[index]

	local progress = 100 * (totalTime - timeLeft)/totalTime
	if ( progress < 99.5 ) then
		guiLabelSetColor ( boosterLabel, 77, 77, 77 )
	else 
		guiLabelSetColor ( boosterLabel, 80, 255, 100 )
	end
	guiProgressBarSetProgress(boosterBar, progress)
end
addEvent("boosterCooldownTick", true)
addEventHandler("boosterCooldownTick", getRootElement(), tickBoosterCooldown)

function tickBoosterDuration(timeLeft, totalTime, index, name, key, enabled)
	local boosterBar = getOrCreateBoosterBar(index, name, key)
	local boosterLabel = boosterLabels[index]

	local progress = 100 - (100 * (totalTime - timeLeft)/totalTime)
	guiLabelSetColor ( boosterLabel, 77, 77, 77 )	
	guiProgressBarSetProgress(boosterBar, progress)
end
addEvent("boosterDurationTick", true)
addEventHandler("boosterDurationTick", getRootElement(), tickBoosterDuration)
*/
