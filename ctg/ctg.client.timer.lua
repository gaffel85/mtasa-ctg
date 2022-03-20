local timerBar = nil
local timerLabel = nil

function tickBombTimer(timeLeft, totalTime)
	if (timerBar == nil) then
		timerBar = guiCreateProgressBar( 0.35, 0.9, 0.3, 0.07, true, nil )
		timerLabel = guiCreateLabel( 0, 0, 1, 1,"", true, timerBar)
		guiLabelSetColor ( timerLabel, 0, 128, 0 )
		guiLabelSetHorizontalAlign ( timerLabel, "center" )
		guiLabelSetVerticalAlign ( timerLabel, "center" )
		guiSetFont(timerLabel, "sa-header")
	end

	if (timeLeft < 10) then
		guiLabelSetColor ( timerLabel, 255, 0, 0 )
		guiSetVisible(timerBar, false)
		setTimer(function() 
			guiSetVisible(timerBar, true)
		end, 500, 1)
	else 
		guiLabelSetColor ( timerLabel, 0, 128, 0 )
	end

	guiSetText(timerLabel, timeLeft.."s")
	local cropppedTime = math.min(totalTime, timeLeft)
	local progress = 100 * cropppedTime/totalTime
	guiProgressBarSetProgress(timerBar, progress)
end
addEvent("bombTimerTick", true)
addEventHandler("bombTimerTick", getRootElement(), tickBombTimer)
