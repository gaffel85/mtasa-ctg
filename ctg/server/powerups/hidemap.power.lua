
local hideMapPower = {
	key = "hidemap",
	name = "Hide map",
    desc = "Hides the map for your opponents.",
	cooldown = function() return getPowerConst().hidemap.cooldown end,
	duration = function() return getPowerConst().hidemap.duration end,
	initCooldown = function() return getPowerConst().hidemap.initCooldown end,
	allowedGoldCarrier = function() return getPowerConst().hidemap.allowedGoldCarrier end,
	charges = function() return getPowerConst().hidemap.charges end,
	rank = function() return getPowerConst().hidemap.rank end,
	onEnable = function(player)
		return true
	end,
	onDisable = function(player)
	end,
	onActivated = function(player, vehicle, state)
		notifyPowerActivated(player, state.name)
        for i, otherPlayer in ipairs(getOpponents(player)) do
            setPlayerHudComponentVisible ( otherPlayer, "radar", false )
        end
	end,
	onDeactivated = function(player, vehicle, state)
         for i, otherPlayer in ipairs(getOpponents(player)) do
            setPlayerHudComponentVisible ( otherPlayer, "radar", true )
        end
	end	
}

addPowerUp(hideMapPower)