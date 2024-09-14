local boosterBars = {}
local boosterLabels = {}

for i = 1, 10 do
    boosterBars[i] = nil
	boosterLabels[i] = nil
end

function tickBoosterCooldown(timeLeft, totalTime, index, name, key)
	local boosterBar = boosterBars[index]
	if ( boosterBar ~= nil ) then
		if ( source ~= localPlayer) then
			guiSetVisible(boosterBar, false)
		else
			guiSetVisible(boosterBar, true)
		end
	end

	if (boosterBar == nil) then
		boosterBar = guiCreateProgressBar( 0.8, 0.35, 0.1, 0.03, true, nil ) --create the gui-progressbar
		boosterLabel = guiCreateLabel( 0, 0,1,1, name.." ("..key..")",true, boosterBar)
		boosterBars[index] = boosterBar
		boosterLabels[index] = boosterLabel
		guiLabelSetColor ( boosterLabel, 0, 128, 0 )
		guiLabelSetHorizontalAlign ( boosterLabel, "center" )
		guiLabelSetVerticalAlign ( boosterLabel, "center" )
		guiSetFont(boosterLabel, "default-bold-small")
	end

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
