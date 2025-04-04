local powers = {}

function addResourcePower(powerUp)
    table.insert(powers, powerUp)
end

function findPowerWithKey(key)
	for i, powerUp in ipairs(powers) do
		if (powerUp.key == key) then
			return powerUp
		end
	end
	return nil
end

function findPowersWithResource(resourceKey)
    local powersWithResouce = {}
	for i, powerUp in ipairs(powers) do
		if (powerUp.resourceKey == resourceKey) then
			table.insert(powersWithResouce, powerUp)
		end
	end
	return powersWithResouce
end

function getPowersData()
	local data = {}
	for i, powerUp in ipairs(powers) do
		local charges = nil
		if powerUp.charges then
			charges = powerUp.charges()
		end
		table.insert(data, {
			key = powerUp.key,
			name = powerUp.name,
			desc = powerUp.desc,
			bindKey = powerUp.bindKey,
			cooldown = powerUp.cooldown(),
			duration = powerUp.duration(),
			charges = charges,
			initCooldown = powerUp.initCooldown(),
			allowedGoldCarrier = powerUp.allowedGoldCarrier(),
			rank = powerUp.rank()
		})
	end
	return data
end

function getPowers()
	return powers
end