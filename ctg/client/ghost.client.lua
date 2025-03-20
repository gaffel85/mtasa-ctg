local ghosts = {}
local defaultAlpha = 150

function setPlayerAsGhost(player, isGhost, invisible)
    if isGhost then
        ghosts[player] = { invisible = invisible }
    else
        ghosts[player] = nil
    end
end

function isPlayerGhost(player)
    return ghosts[player] ~= nil
end

function isInvisibleGhost(player)
    return ghosts[player] and ghosts[player].invisible
end

function makeMeGhostForMyself(player, vehicle)
    setElementAlpha( vehicle, defaultAlpha )
    setElementAlpha( player, defaultAlpha )
    
    for i, otherPlayer in ipairs(getElementsByType("player")) do
        if otherPlayer ~= player then
            setElementCollidableWith( vehicle, getPedOccupiedVehicle ( otherPlayer ) , false)
        end
    end
end

function makeOtherPlayerGhostForMe(player, vehicle, invisible)
    local alpha = defaultAlpha
    if (invisible) then
        alpha = 0
    end
    setElementAlpha( vehicle, alpha )
    setElementAlpha( player, alpha )
    if (invisible) then
        setVehicleOverrideLights ( vehicle, 1 ) 
	    setPlayerNametagShowing ( player, false )
    end

    setElementCollidableWith( vehicle, getPedOccupiedVehicle ( getLocalPlayer() ) , false)
end

function onMakeGhostFromServer(player, invisible)
    if isPlayerGhost(player) then
        return
    end

    setPlayerAsGhost(player, true, invisible)
    local vehicle = getPedOccupiedVehicle( player )
    if ( getLocalPlayer() == player ) then
        makeMeGhostForMyself(player, vehicle)
    else 
        makeOtherPlayerGhostForMe(player, vehicle, invisible)
    end	
end
addEvent("makeGhostFromServer", true)
addEventHandler("makeGhostFromServer", getRootElement(), onMakeGhostFromServer)

function unmakeMeGhostForMyself(player, vehicle)
    setElementAlpha( vehicle, 255 )
    setElementAlpha( player, 255 )
    setVehicleOverrideLights ( vehicle, 0 ) 
	setPlayerNametagShowing ( player, true )
    
    for i, otherPlayer in ipairs(getElementsByType("player")) do
        if not isPlayerGhost(otherPlayer) then
            setElementCollidableWith( vehicle, getPedOccupiedVehicle ( otherPlayer ) , true)
        end
    end
end

function unmakeOtherPlayerGhostForMe(player, vehicle)
    setElementAlpha( vehicle, 255 )
    setElementAlpha( player, 255 )

    setElementCollidableWith( vehicle, getPedOccupiedVehicle ( getLocalPlayer() ) , true)
end

function onUnmakeGhostFromServer(player)
    if not isPlayerGhost(player) then
        return
    end

    setPlayerAsGhost(player, false, false)
    local vehicle = getPedOccupiedVehicle( player )
    if ( getLocalPlayer() == player ) then
        unmakeMeGhostForMyself(player, vehicle)
    else 
        unmakeOtherPlayerGhostForMe(player, vehicle)
    end	
end
addEvent("unmakeGhostFromServer", true)
addEventHandler("unmakeGhostFromServer", getRootElement(), onUnmakeGhostFromServer)

addEventHandler("onClientVehicleEnter", getRootElement(),
    function(thePlayer, seat)
        outputChatBox("Someone entered the vehicle")
        if thePlayer == getLocalPlayer() then
            outputChatBox("You entered the vehicle")
            if isPlayerGhost(thePlayer) then
                makeMeGhostForMyself(thePlayer, source)
            end
        else 
            outputChatBox("Someone else entered the vehicle")
            -- loop over all ghosts and apply
            if (isPlayerGhost(thePlayer)) then
                makeOtherPlayerGhostForMe(ghostPlayer, source, isInvisibleGhost(thePlayer))
            end
        end 
    end
)