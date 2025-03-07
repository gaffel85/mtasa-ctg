function askForTeleport(player, secondParam)
	local leader = findLeader(player)
	if (not leader or leader == player) then
		-- outputChatBox("No leader found")
		return
	end
	-- outputChatBox("Leader is "..getPlayerName(leader))
	triggerClientEvent(leader, "reportLastTransform", resourceRoot, 2, "telportTo", player)
end

function teleportTo(player, transform)
	local vehicle = getPedOccupiedVehicle(player)
	if (not vehicle) then
		return
	end
	setElementPosition(vehicle, transform.x, transform.y, transform.z)
	setElementRotation(vehicle, transform.rx, transform.ry, transform.rz)
	setElementVelocity(vehicle, transform.vx, transform.vy, transform.vz)
	setElementAngularVelocity(vehicle, transform.vrx, transform.vry, transform.vrz)
end

-- function that finds the leader by first taking the goldCarrier, if there is one, and then the player that is closest to the gold
function findLeader(me)
	local goldCarrier = getGoldCarrier()
	if goldCarrier then
		-- outputChatBox("Found gold carrier as leader")
		return goldCarrier
	end

	local players = getElementsByType("player")
	local closestPlayer = nil
	local closestDistance = 999999999
	for k, player in ipairs(players) do
		local distance = getDistanceToGold(player)
		-- outputChatBox("Distance to gold for player: "..getPlayerName(player))
		if (distance < closestDistance and player ~= me) then
			closestPlayer = player
			closestDistance = distance
			-- outputChatBox("Best player so far")
		end
	end
	return closestPlayer
end

function getDistanceToGold(player)
	local gold = getLastGoldSpawn()
	if not gold then
		return 999999999
	end
	local x, y, z = getElementPosition(player)
	local x2, y2, z2 = gold.x, gold.y, gold.z
	return getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
end

function isFarEnoughFromLeader(player)
	local leader = findLeader(player)
	--outputDebugString("isFarEnoughFromLeader  for "..inspect(player).." "..inspect(leader))
	if not leader then
		return false
	end
	local playerPosition = nil
	if player then
		playerPosition = getElementPosition(player)
	else
		-- outputChatBox("Player not null")
	end
	local leaderPosition = nil
	if leader then
		leaderPosition = getElementPosition(leader)
	else
		-- outputChatBox("Leader not null")
	end
	if leaderPosition and playerPosition then
		local x1, y1, z1 = getElementPosition(player)
		local x2, y2, z2 = getElementPosition(leader)
		--outputDebugString("1  for "..x1.." "..y1.." "..z1.." ")
		--outputDebugString("2  for "..x2.." "..y2.." "..z2.." ")
		local distance = getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2)
		return distance > getPowerConst().teleport.minDistance
	else
		-- outputChatBox("leaderPosition or playerPosition null")
	end
	return false
end

function spawnCloseToLeader(player)
	local leader = findLeader(player)
	if (not leader or leader == player) then
		return
	end

	local vehicle = getPedOccupiedVehicle(player)
	if (not vehicle) then
		return
	end

	local leaderX, leaderY, leaderZ = getElementPosition(leader)
	local spwans = getSpawnPoints()
	local spawn = positionCloseTo(spwans, {x = leaderX, y = leaderY, z = leaderZ}, 0)
	local x, y, z = coordsFromEdl(spawn)
	local rx, ry, rz = rotFromEdl(spawn)
	
	setElementPosition(vehicle, x, y, z)
	setElementRotation(vehicle, rx, ry, rz)
	setElementVelocity(vehicle, 0, 0, 0)
	setElementAngularVelocity(vehicle, 0, 0, 0)
end