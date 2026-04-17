local victorySequenceDuration = 5000

addEventHandler("onResourceStart", resourceRoot, function()
    victorySequenceDuration = getConst().victorySequenceDuration or 5000
end)

addEvent("onServerVictorySequenceStart", true)

function startVictorySequence(winner, forcedSequenceId)
    local sequenceId = forcedSequenceId
    if not sequenceId then
        local quotas = getConst().victoryQuotas or { matrix = 1, bulletTime = 1, shockwave = 1, orbital = 1, getaway = 1 }
        local weightTable = {
            { id = 1, weight = quotas.matrix or 1 },
            { id = 2, weight = quotas.bulletTime or 1 },
            { id = 3, weight = quotas.shockwave or 1 },
            { id = 4, weight = quotas.orbital or 1 },
            { id = 5, weight = quotas.getaway or 1 }
        }
        
        local totalWeight = 0
        for _, item in ipairs(weightTable) do
            totalWeight = totalWeight + item.weight
        end
        
        local randomWeight = math.random() * totalWeight
        local currentWeight = 0
        for _, item in ipairs(weightTable) do
            currentWeight = currentWeight + item.weight
            if randomWeight <= currentWeight then
                sequenceId = item.id
                break
            end
        end
        sequenceId = sequenceId or 1
    end
    
    local winnersTeam = getCtgTeam(winner)
    local winningVehicle = getPedOccupiedVehicle(winner)
    
    outputServerLog("OLA: Starting victory sequence " .. tostring(sequenceId))
    
    local enemyVehicles = {}
    for _, player in ipairs(getElementsByType("player")) do
        if getCtgTeam(player) ~= winnersTeam then
            local veh = getPedOccupiedVehicle(player)
            if veh then
                table.insert(enemyVehicles, veh)
            end
        end
    end

    -- Trigger client-side for all players
    triggerClientEvent("onClientVictorySequenceStart", root, winner, sequenceId, victorySequenceDuration, enemyVehicles)

    -- Server-side specific logic for sequences
    if sequenceId == 1 then -- Matrix Freeze
        for _, veh in ipairs(getElementsByType("vehicle")) do
            setElementFrozen(veh, true)
        end
    elseif sequenceId == 2 then -- Bullet Time
        setGameSpeed(0.05)
    elseif sequenceId == 3 then -- Kinetic Shockwave
        setElementFrozen(winningVehicle, true)
        setElementData(winningVehicle, "invulnerable", true)
        
        local wx, wy, wz = getElementPosition(winningVehicle)
        -- Add a visual blast at the winner's position
        createExplosion(wx, wy, wz, 1) 

        for _, veh in ipairs(enemyVehicles) do
            local ex, ey, ez = getElementPosition(veh)
            local dist = getDistanceBetweenPoints3D(wx, wy, wz, ex, ey, ez)
            if dist < 50 then
                -- Add smaller visual explosions at each hit vehicle to show impact
                createExplosion(ex, ey, ez, 0)
                local vx = (ex - wx) * 0.5
                local vy = (ey - wy) * 0.5
                local vz = 0.5
                setElementVelocity(veh, vx, vy, vz)
            end
        end
    elseif sequenceId == 4 then -- Orbital Strike
        for _, player in ipairs(getElementsByType("player")) do
            if getCtgTeam(player) == winnersTeam then
                local veh = getPedOccupiedVehicle(player)
                if veh then
                    setElementFrozen(veh, true)
                    setElementData(veh, "invulnerable", true)
                end
            end
        end
        
        setTimer(function()
            for _, veh in ipairs(enemyVehicles) do
                local ex, ey, ez = getElementPosition(veh)
                createExplosion(ex, ey, ez, 10) -- Large explosion effect
                blowVehicle(veh)
            end
        end, 2000, 1)
    elseif sequenceId == 5 then -- Automated Getaway
        setElementData(winningVehicle, "invulnerable", true)
        setPedControlState(winner, "accelerate", true)
        setPedControlState(winner, "vehicle_left", false)
        setPedControlState(winner, "vehicle_right", false)
        setPedControlState(winner, "brake_reverse", false)
    end

    -- Cleanup timer
    setTimer(function()
        endVictorySequence(sequenceId)
    end, victorySequenceDuration, 1)
end

function endVictorySequence(sequenceId)
    -- Global cleanup for all sequences
    for _, veh in ipairs(getElementsByType("vehicle")) do
        setElementFrozen(veh, false)
        setElementData(veh, "invulnerable", nil)
    end

    -- Reset game speed for Bullet Time
    if sequenceId == 2 then
        setGameSpeed(1.0)
    end
    
    -- Reset control states for Automated Getaway
    if sequenceId == 5 then
        local winners = getElementsByType("player") -- Simple fallback to clear all just in case
        for _, p in ipairs(winners) do
            setPedControlState(p, "accelerate", false)
        end
    end

    outputServerLog("OLA: Victory sequence finished")
    triggerEvent("onVictorySequenceFinished", root)
end

addEvent("requestVictorySequence", true)
addEventHandler("requestVictorySequence", resourceRoot, function(sequenceId)
    -- 'client' is the player who triggered the event
    local winner = client
    if not isElement(winner) then
        winner = getElementsByType("player")[1]
    end
    startVictorySequence(winner, sequenceId)
end)
