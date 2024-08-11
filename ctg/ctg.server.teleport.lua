function askForTeleport(player)
	local player = source
	local leader = findLeader()
	if (leader == nil or leader == player) then
		return
	end

	triggerClientEvent(leader, "reportLastTransform", resourceRoot, 2, "telportTo", player)
end

function teleportTo(player, transform)
	local vehicle = getPedOccupiedVehicle(player)
	if (vehicle == nil) then
		return
	end
	setElementPosition(vehicle, transform.x, transform.y, transform.z)
	setElementRotation(vehicle, transform.rx, transform.ry, transform.rz)
	setElementVelocity(vehicle, transform.vx, transform.vy, transform.vz)
	setElementAngularVelocity(vehicle, transform.vrx, transform.vry, transform.vrz)
end

-- function that finds the leader by first taking the goldCarrier, if there is one, and then the player that is closest to the gold
function findLeader()
	local goldCarrier = getGoldCarrier()
	if goldCarrier ~= nil then
		return goldCarrier
	end

	local players = getElementsByType("player")
	local closestPlayer = nil
	local closestDistance = 999999999
	for k, player in ipairs(players) do
		local distance = getDistanceToGold(player)
		if distance < closestDistance then
			closestPlayer = player
			closestDistance = distance
		end
	end
	return closestPlayer
end

function distanceToGold(player)
	local gold = getLastGoldSpawn()
	if gold == nil then
		return 999999999
	end
	local x, y, z = getElementPosition(player)
	local x2, y2, z2 = coordsFromEdl(gold)
	return getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
end

function bindXForTeleport()
	bindKey(source, "x", "down", askForTeleport)
end
addEventHandler("ondPlayerJoin", getRootElement(), bindXForTeleport)

-- unbind x key when player quits
function unbindXForTeleport()
	unbindKey(source, "x")
end
addEventHandler("onPlayerQuit", getRootElement(), unbindXForTeleport)