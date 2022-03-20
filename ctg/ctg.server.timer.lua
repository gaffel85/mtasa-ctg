local bombEndTime

addEvent("bombTimesUp")

function bombTimeLeft() 
	local currentTime = getRealTime()
	return bombEndTime - currentTime.timestamp
end

function resetBomb()
	setBombTime ( BOMB_START_SECONDS )
end

function setBombTime(duration)
	local time = getRealTime()
	bombEndTime = time.timestamp + duration
end

function addBombTime(duration)
	setBombTime ( bombTimeLeft() + duration )
end

function tickBombTimer()
	if (getGameState() == GAME_STATE_LOBBY) then
		return
	end

	if (getGameState() == GAME_STATE_PREPARE_ROUND) then
		timeLeft = bombTimeLeft()
		if ( timeLeft < 0 ) then
			startActiveRound()
		else
			showPrepareRoundTimer(timeLeft)
		end
		return
	end

	local players = getElementsByType ( "player" )
	if(getBombHolder() ~= nil and #players > 0) then
		timeLeft = bombTimeLeft()
		if (timeLeft < 12 and timeLeft > 10) then
			triggerClientEvent("timesAlmostUp", getBombHolder())
		end

		if ( timeLeft < 0 ) then
			triggerEvent("bombTimesUp", getBombHolder())
		else
			triggerClientEvent("bombTimerTick", getBombHolder(), timeLeft, BOMB_START_SECONDS)
		end
	end
end
setTimer(tickBombTimer, 1000, 0)

addCommandHandler ( "changetime",
    function ( thePlayer, command, time )
        local timeNumber = tonumber ( time )
		if ( timeNumber > 0 ) then
			setBombTime(timeNumber)
		end
    end
)
