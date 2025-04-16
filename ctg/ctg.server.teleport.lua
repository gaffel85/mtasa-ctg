function askForTeleport(player, locationsAgo)
	local leader = findLeader(player)
	if (not leader or leader == player) then
		-- outputChatBox("No leader found")
		return
	end
	-- outputChatBox("Leader is "..getPlayerName(leader))
	askForLocationNbr(player, leader, locationsAgo, "telportTo")
end

function askForLocationNbr(asker, targetPlayer, locationsAgo, targetFunction, param4, param5, param6)
	triggerClientEvent(targetPlayer, "reportLastTransform", resourceRoot, locationsAgo, targetFunction, asker, param4, param5, param6)
end

function askForLocationBackInTime(asker, targetPlayer, timeAgo, targetFunction, param4, param5, param6)
	triggerClientEvent(targetPlayer, "reportLastTransformTimeAgo", resourceRoot, timeAgo, targetFunction, asker, param4, param5, param6)
end

-- 0, 0, -0.85
-- 24, 358, 247
function teleportTo(player, transform)
	local vehicle = getPedOccupiedVehicle(player)
	if (not vehicle) then
		return
	end
	local radius, x1, y1, z1, x2, y2, z2 = getVehicleSizeData(vehicle)
	local distanceToGroundVector = { x = 0, y = 0, z = z1 }
	local rotated_vector = rotate_euler(distanceToGroundVector, transform.rx, transform.ry, transform.rz)
	local intersection_z = z_axis_intersection(rotated_vector, rotated_vector)

	outputChatBox("Original z: "..z1.." Intersection z: "..intersection_z)
	outputChatBox("Rotation vector "..inspect(transform.rx.." "..transform.ry.." "..transform.rz))

	setElementPosition(vehicle, transform.x, transform.y, transform.z + 2)
	setElementRotation(vehicle, transform.rx, transform.ry, transform.rz)
	setElementVelocity(vehicle, transform.vx, transform.vy, transform.vz)
	setElementAngularVelocity(vehicle, transform.vrx, transform.vry, transform.vrz)
end

function teleportToOr(player, transform, targetPos, optionalPos)
	local vehicle = getPedOccupiedVehicle(player)
	if (not vehicle) then
		return
	end

	--outputServerLog("Transform: "..inspect(transform))
	--outputServerLog("Target pos: "..inspect(targetPos))
	--outputServerLog("Optional pos: "..inspect(optionalPos))

	local transformDistanceToTarget = getDistanceBetweenPoints3D(transform.x, transform.y, transform.z, targetPos.x, targetPos.y, targetPos.z)
	local optionalPosDistanceToTarget = getDistanceBetweenPoints3D(optionalPos.x, optionalPos.y, optionalPos.z, targetPos.x, targetPos.y, targetPos.z)


	--outputServerLog("Transform distance to target: "..transformDistanceToTarget)
	--outputServerLog("Optional pos distance to target: "..optionalPosDistanceToTarget)
	if transformDistanceToTarget < optionalPosDistanceToTarget then
		--outputServerLog("Teleporting to transform")
		teleportTo(player, transform)
	else
		outputServerLog("Teleporting to optional pos")
		setElementPosition(vehicle, optionalPos.x, optionalPos.y, optionalPos.z + 2)
	end
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

function findTargetPos()
	local goldCarrier = getGoldCarrier()
	if goldCarrier then
		-- outputChatBox("Found gold carrier as leader")
		return getElementPosition(goldCarrier)
	end

	local gold = getLastGoldSpawn()
	if not gold then
		return nil
	end
	return gold.x, gold.y, gold.z
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

	local leaderX, leaderY, leaderZ = getElementPosition(leader)
	spawnCloseTo(player, {x=leaderX, y=leaderY, z=leaderZ})
end

function spawnCloseToMeanPositionOfAllPlayers(player)
	local players = getElementsByType("player")
	local x = 0
	local y = 0
	local z = 0
	local count = 0
	for k, player in ipairs(players) do
		local px, py, pz = getElementPosition(player)
		x = x + px
		y = y + py
		z = z + pz
		count = count + 1
	end
	x = x / count
	y = y / count
	z = z / count
	spawnCloseTo(player, {x=x, y=y, z=z})
end

function spawnCloseTo(player, pos)
	local vehicle = getPedOccupiedVehicle(player)
	if (not vehicle) then
		return
	end

	local spwans = getSpawnPoints()
	local spawn = positionCloseTo(spwans, pos, 0)
	local x, y, z = coordsFromEdl(spawn)
	local rx, ry, rz = rotFromEdl(spawn)

	makePlayerGhost(player, 2, true, false)
	
	setElementPosition(vehicle, x, y, z)
	setElementRotation(vehicle, rx, ry, rz)
	setElementVelocity(vehicle, 0, 0, 0)
	setElementAngularVelocity(vehicle, 0, 0, 0)
end

addCommandHandler("teleportAgo", function(thePlayer, command, timeAgo)
	local timeAgoNbr = tonumber(timeAgo)
	outputChatBox("Teleporting to location time ago "..timeAgoNbr)
    askForLocationBackInTime(thePlayer, thePlayer, timeAgoNbr, "teleportTo")
end)

addCommandHandler("teleportIndex", function(thePlayer, command, locationNbr)
	local locationNbrNbr = tonumber(locationNbr)
	outputChatBox("Teleporting to location index "..locationNbrNbr)
    askForLocationNbr(thePlayer, thePlayer, locationNbrNbr, "teleportTo")
end)