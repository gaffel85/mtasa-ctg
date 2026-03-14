local cinematicCamera = {
	key = "cinematic",
	name = "Cinematic camera",
    desc = "Changes to a helicopter view for all player. This will make it harder for all to see where they drive and affect there accuracy.",
	cooldown = function() return getPowerConst().cinematic.cooldown end,
	duration = function() return getPowerConst().cinematic.duration end,
	initCooldown = function() return getPowerConst().cinematic.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().cinematic.allowedGoldCarrier end,
	charges = function() return getPowerConst().cinematic.charges end,
	rank = function() return getPowerConst().cinematic.rank end,
	onEnable = function(player)
		-- outputChatBox("superCar enabled "..getPlayerName(player))
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		notifyPowerActivated(player, state.name)
        for i, otherPlayer in ipairs(getElementsByType("player")) do
            -- if the player is in a vehicle
            --if otherPlayer ~= player then
            triggerClientEvent(otherPlayer, "setCinematicCameraAngle", otherPlayer)
            --end
        end
	end,
	onDeactivated = function(player, vehicle, state)
		for i, otherPlayer in ipairs(getElementsByType("player")) do
            -- if the player is in a vehicle
            --if otherPlayer ~= player then
        	triggerClientEvent(otherPlayer, "resetCameraAngle", otherPlayer)
            --end
        end
	end	
}

if registerTemporaryPower then
    registerTemporaryPower("camera_chaos", {
        name = cinematicCamera.name,
        description = cinematicCamera.desc,
        iconPath = "img/helicam.png",
        duration = cinematicCamera.duration(),
        onActivate = function(player)
            local vehicle = getPedOccupiedVehicle(player)
            cinematicCamera.onActivated(player, vehicle, {name = cinematicCamera.name})
            
            -- Set a timer to deactivate it, since cinematic camera seems to be designed with a duration
            local duration = cinematicCamera.duration()
            setTimer(function()
                if isElement(player) then
                    cinematicCamera.onDeactivated(player, getPedOccupiedVehicle(player), {})
                end
            end, duration * 1000, 1)
        end
    })
end
