function makeSelfGhost(player, vehicle)
    setElementAlpha( vehicle, 150 )
    setElementAlpha( player, 0 )

    if (isGhost) then
        for _, hardPlayer in ipairs(hardPlayers) do
            setElementCollidableWith( vehicle, getPedOccupiedVehicle ( hardPlayer ) , false)
        end
    end
end

function makePlayerGhostForOthers(player, vehicle)
    setElementAlpha( vehicle, 150 )
    setElementAlpha( player, 0 )

    if (isGhost) then
        setElementCollidableWith( vehicle, getPedOccupiedVehicle ( getLocalPlayer() ) , false)
    end
end

function onMakeGhostFromServer()
	local player = source
    local vehicle = getPedOccupiedVehicle( player )
    if ( getLocalPlayer() == player ) then
        makeSelfGhost(player, vehicle)
    else 
        makePlayerGhostForOthers(player, vehicle)
    end	
end
addEvent("makeGhostFromServer", true)
addEventHandler("makeGhostFromServer", getRootElement(), onMakeGhostFromServer)