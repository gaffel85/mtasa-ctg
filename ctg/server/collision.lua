local shieldedPlayers = {}

function isShielded(player)
    return shieldedPlayers[player] ~= nil
end

function addShieldedPlayer(player, hits, duration)
    local oldVal = shieldedPlayers[player]
    if oldVal then
        if oldVal.hits > hits then
            return
        end
        local oldShieldTimer = oldVal.timer
        if oldShieldTimer then
            killTimer(oldShieldTimer)
        end
    end

    shieldedPlayers[player] = { hits = hits, duration = duration }
    triggerClientEvent(getRootElement(), "onShieldAddedFromServer", getRootElement(), player)
end

function removeShieldedPlayer(player)
    local oldShieldTimer = shieldedPlayers[player] and shieldedPlayers[player].timer
    if oldShieldTimer then
        killTimer(oldShieldTimer)
    end
    shieldedPlayers[player] = nil
    triggerClientEvent(getRootElement(), "onShieldRemovedFromServer", resourceRoot, player)
end

function increaseHits(player)
    if shieldedPlayers[player] then
        local newVal = shieldedPlayers[player].hits + 1
        shieldedPlayers[player].hits = newVal
        return newVal
    end
    return 0
end

local function getVehicleSpeed(vehicle)
    if not vehicle then return 0 end
    local vx, vy, vz = getElementVelocity(vehicle)
    return math.sqrt(vx^2 + vy^2 + vz^2) * 180
end

function collisisionWithPlayer(otherPlayer, damage)
    local goldCarrier = getGoldCarrier()
    local notGoldCarrier = nil
    if otherPlayer == goldCarrier then
        notGoldCarrier = client
    elseif client == goldCarrier then
        notGoldCarrier = otherPlayer
    end

    if not notGoldCarrier then
        return
    end

    -- Momentum check
    local attackerVehicle = getPedOccupiedVehicle(notGoldCarrier)
    local carrierVehicle = getPedOccupiedVehicle(goldCarrier)
    
    if attackerVehicle and carrierVehicle then
        local momentumCfg = getElementData(resourceRoot, "props").momentum
        local attackerSpeed = getVehicleSpeed(attackerVehicle)
        local carrierSpeed = getVehicleSpeed(carrierVehicle)

        local rule1 = attackerSpeed > momentumCfg.Rule1MinSpeed
        local rule2 = attackerSpeed > (carrierSpeed + momentumCfg.Rule2RelativeSpeed)
        
        -- Use the "isCapableOfStealing" state from the client as a fallback to account for collision-induced speed loss
        local isCapable = getElementData(notGoldCarrier, "isCapableOfStealing")

        if not rule1 and not rule2 and not isCapable then
            return
        end
    end

    if isShielded(goldCarrier) then
        local newHits = increaseHits(goldCarrier)
        if newHits <= 0 then
            local oldShieldTimer = shieldedPlayers[goldCarrier].timer
            if not oldShieldTimer then
                shieldedPlayers[goldCarrier].timer = setTimer(function()
                    removeShieldedPlayer(goldCarrier)
                    triggerClientEvent(getRootElement(), "onShieldRemovedFromServer", resourceRoot, goldCarrier)
                end, shieldedPlayers[goldCarrier].duration * 1000, 1)
            end
        end
    else 
        changeGoldCarrier(notGoldCarrier)
    end
end
addEvent("onCollisionWithPlayer", true)
addEventHandler("onCollisionWithPlayer", getRootElement(), collisisionWithPlayer)