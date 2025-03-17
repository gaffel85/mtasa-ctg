local ghosts = {}

function setPlayerAsGhost(player, isGhost)
    ghosts[player] = isGhost
end

function isPlayerGhost(player)
    return ghosts[player]
end

function makeSelfGhost(player, vehicle, invisible)
    local alpha = 150
    if (invisible) then
        alpha = 0
    end
    setElementAlpha( vehicle, alpha )
    setElementAlpha( player, alpha )
    if (invisible) then
        setVehicleOverrideLights ( vehicle, 1 ) 
	    setPlayerNametagShowing ( player, false )
    end
    
    for i, otherPlayer in ipairs(getElementsByType("player")) do
        if otherPlayer ~= player then
            setElementCollidableWith( vehicle, getPedOccupiedVehicle ( otherPlayer ) , false)
        end
    end
end

function makePlayerGhostForOthers(player, vehicle)
    setElementAlpha( vehicle, 150 )
    setElementAlpha( player, 0 )

    setElementCollidableWith( vehicle, getPedOccupiedVehicle ( getLocalPlayer() ) , false)
end

function onMakeGhostFromServer()
	local player = source
    if isPlayerGhost(player) then
        return
    end

    setPlayerAsGhost(player, true)
    local vehicle = getPedOccupiedVehicle( player )
    if ( getLocalPlayer() == player ) then
        makeSelfGhost(player, vehicle)
    else 
        makePlayerGhostForOthers(player, vehicle)
    end	
end
addEvent("makeGhostFromServer", true)
addEventHandler("makeGhostFromServer", getRootElement(), onMakeGhostFromServer)

function unmakeSelfGhost(player, vehicle)
    setElementAlpha( vehicle, 255 )
    setElementAlpha( player, 255 )
    setVehicleOverrideLights ( vehicle, 0 ) 
	setPlayerNametagShowing ( player, true )
    
    for i, otherPlayer in ipairs(getElementsByType("player")) do
        if not isGhost(otherPlayer) then
            setElementCollidableWith( vehicle, getPedOccupiedVehicle ( otherPlayer ) , true)
        end
    end
end

function unmakePlayerGhostForOthers(player, vehicle)
    setElementAlpha( vehicle, 255 )
    setElementAlpha( player, 255 )

    setElementCollidableWith( vehicle, getPedOccupiedVehicle ( getLocalPlayer() ) , true)
end

function onUnmakeGhostFromServer()
	local player = source
    if not isPlayerGhost(player) then
        return
    end

    setPlayerAsGhost(player, false)
    local vehicle = getPedOccupiedVehicle( player )
    if ( getLocalPlayer() == player ) then
        unmakeSelfGhost(player, vehicle)
    else 
        unmakePlayerGhostForOthers(player, vehicle)
    end	
end
addEvent("unmakeGhostFromServer", true)
addEventHandler("unmakeGhostFromServer", getRootElement(), onUnmakeGhostFromServer)