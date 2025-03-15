local PHYSICS_WARNING_TEXT_ID = 32590191

function applyPhysics(player, who)
    if who == 0
        for i, otherPlayer in ipairs(getOpponents(player)) do
            applyPhysicsToOpponent(otherPlayer)
        end
    elseif who == 1 then
        for i, otherPlayer in ipairs(getElementsByType("player")) do
            if otherPlayer ~= player then
                applyPhysicsToOpponent(otherPlayer)
            end
        end
    else
        for i, otherPlayer in ipairs(getElementsByType("player")) do
            if otherPlayer ~= player then
                applyPhysicsToOpponent(otherPlayer)
            end
        end
    end
end

function applyPhysicsToOpponent(opponent)
    -- randomly choose a physics, 30% for each
    local random = math.random(1, 100)
    if random <= 33 then
        applyDirectionPhysics(opponent)
    elseif random <= 66 then
        applyNegativeVelocityPhysics(opponent)
    else
        applyJumpAndRotatePhysics(opponent)
    end
end

function applyDirectionPhysics(opponent)
    local vehicle = getPedOccupiedVehicle(opponent)
    if vehicle then
        local rx, ry, rz = getElementRotation(vehicle)
        setElementRotation(vehicle, rx, ry, rz + math.random(-270, 270))
    end
end

function applyNegativeVelocityPhysics(opponent)
    local vehicle = getPedOccupiedVehicle(opponent)
    if vehicle then
        local vx, vy, vz = getElementVelocity(vehicle)
        setElementVelocity(vehicle, vx * -0.3, vy * -0.3, vz * -0.3)
    end
end

function applyJumpAndRotatePhysics(opponent)
    local vehicle = getPedOccupiedVehicle(opponent)
    if vehicle then
        local vx, vy, vz = getElementVelocity(vehicle)
        local newVelocityVector = { x = vx, y = vy, z = vz + 0.2 }
        setElementVelocity(vehicle, newVelocityVector.x, newVelocityVector.y, newVelocityVector.z)
        local vrx, vry, vrz = getElementAngularVelocity(vehicle)
        setElementAngularVelocity(vehicle, vrx + math.random(-10, 10), vry + math.random(-10, 10), vrz + math.random(-10, 10))

    end
end

local physicsPower = {
	key = "physics",
	name = "Bättre fysik, tack!",
    desc = "Applies some \"improved\" physics to your opponents. This might lead to unforeseen consequences and might backfire.",
	cooldown = function() return getPowerConst().physics.cooldown end,
	duration = function() return getPowerConst().physics.duration end,
	initCooldown = function() return getPowerConst().physics.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().physics.allowedGoldCarrier end,
	charges = function() return getPowerConst().physics.charges end,
	rank = function() return getPowerConst().physics.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
        local who = 0 -- 0 = opponents, 1 = all except player, 2 = all
        -- randomly choose who to apply physics to, 50% opponents, 30% all except player, 20% all
        local random = math.random(1, 100)
        local msg = getPlayerName(player).." will give you some physics in"
        if random <= 50 then
            for i, otherPlayer in ipairs(getOpponents(player)) do
                countDownTextForPlayer(3, otherPlayer, msg, 0.5 0.3, 255, 255, 255, 255, 3)
            end
            who = 0
        elseif random <= 80 then
            who = 1
            for i, otherPlayer in ipairs(getElementsByType("player")) do
                if otherPlayer ~= player then
                    countDownTextForPlayer(3, otherPlayer, msg, 0.5 0.3, 255, 255, 255, 255, 3)
                end
            end
        else
            who = 2
            for i, otherPlayer in ipairs(getElementsByType("player")) do
                if otherPlayer ~= player then
                    countDownTextForPlayer(3, otherPlayer, msg, 0.5 0.3, 255, 255, 255, 255, 3)
                end
            end
            countDownTextForPlayer(3, player, "It backfired! Prepare for physics!", 0.5 0.3, 255, 255, 255, 255, 3)
        end

        
        setTimer(function()
            applyPhysics(player, who)
        end, 3000, 1)
	end,
	onDeactivated = function(player, vehicle, state)
	end	
}

addPowerUp(physicsPower)