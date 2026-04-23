local function syncVehicleHealthToPed()
	if isPedDead(localPlayer) then return end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then return end
	
	local health = getElementHealth(vehicle)
	local progress = (math.max(health, 250) - 250) / 750
	setElementHealth(localPlayer, progress * 100)
end

addEventHandler ( "onClientVehicleDamage", root, function ( attacker, weapon, loss )
	if ( getVehicleOccupant ( source ) ~= localPlayer ) then
		return
	end	
	syncVehicleHealthToPed()
end )

setTimer(syncVehicleHealthToPed, 500, 0)

function onCollision(collider, damageImpulseMag)
	if ( collider and localPlayer == getGoldCarrier() ) then
		if ( source == getPedOccupiedVehicle(localPlayer) and getElementType ( collider ) == "vehicle" ) then
			local fDamageMultiplier = getVehicleHandling(source).collisionDamageMultiplier
			local damage = fDamageMultiplier * damageImpulseMag
			-- outputChatBox("D: "..damage.." F: "..inspect(damageImpulseMag).." M: "..fDamageMultiplier)
			local otherPlayer = getVehicleOccupant(collider)
			if ( otherPlayer ~= false) then
				triggerServerEvent("onCollisionWithPlayer", resourceRoot, otherPlayer, damage)
			end
		end
	end
end
addEventHandler("onClientVehicleCollision", getRootElement(), onCollision)

function flipIfNeeded(vehicle)
    if not vehicle or not isElement(vehicle) then return end
	local rx,ry,rz = getElementRotation ( vehicle )
	if rx > 90 and rx < 270 or ry > 90 and ry < 270 then
		local posX, posY, posZ = getElementPosition ( vehicle )
		setElementPosition (vehicle, posX, posY, posZ + 2)
		setElementRotation (vehicle, 0, 0, rz)
	end
end

local isRespawning = false
local screenW, screenH = guiGetScreenSize()

function paralyzeAndRepairCar(vehicle, isManual)
	if isRespawning then return end
	isRespawning = true

	local location = findLocationClosestToTimeAgo(2)
	local goldLocation = findLocationClosestToTimeAgo(0) -- Most recent ground location

	if not location then
		-- Fallback to old behavior if no location found
		toggleAllControls(false, true, false)
        if vehicle and isElement(vehicle) then
		    setVehicleDamageProof(vehicle, true)
            fixVehicle(vehicle)
		    flipIfNeeded(vehicle)
        end
		triggerServerEvent("clientText", resourceRoot, "showRepairingCar")
		triggerServerEvent("repairCar", resourceRoot, localPlayer)
		setTimer(function()
			toggleAllControls(true, true, true)
            if vehicle and isElement(vehicle) then
			    setVehicleDamageProof(vehicle, false)
            end
			isRespawning = false
		end, getConst().repairTime * 1000, 1)
		return
	end

	fadeCamera(false, 1.0)
	
	if not isManual then
		local function drawRespawnMessage()
			dxDrawText("Your vehicle was too damaged! Respawning...", 0, 0, screenW, screenH, tocolor(255, 255, 255, 255), 3, "default-bold", "center", "center")
		end
		addEventHandler("onClientRender", root, drawRespawnMessage)
		setTimer(function() removeEventHandler("onClientRender", root, drawRespawnMessage) end, 1000, 1)
	end

	setTimer(function()
		fadeCamera(true, 1.0)
		local gx, gy, gz = nil, nil, nil
		if goldLocation then
			gx, gy, gz = goldLocation.x, goldLocation.y, goldLocation.z
		end
		triggerServerEvent("onRespawnOnDamageTeleport", resourceRoot, 
			location.x, location.y, location.z, 
			location.rx, location.ry, location.rz, 
			location.vx, location.vy, location.vz,
			location.avx, location.avy, location.avz,
			gx, gy, gz)

		local countdown = 2
		local function drawCountdown()
			if countdown > 0 then
				dxDrawText(tostring(countdown), 0, 0, screenW, screenH, tocolor(255, 255, 255, 255), 5, "default-bold", "center", "center")
			end
		end
		addEventHandler("onClientRender", root, drawCountdown)

		setTimer(function() countdown = 1 end, 1000, 1)

		setTimer(function()
			countdown = 0
			removeEventHandler("onClientRender", root, drawCountdown)
			triggerServerEvent("onRespawnOnDamageRelease", resourceRoot)
			isRespawning = false
		end, 2000, 1)
	end, 1000, 1)
end

addEventHandler("onClientPlayerWasted", localPlayer, function()
	paralyzeAndRepairCar(getPedOccupiedVehicle(localPlayer))
end)

function manualRepair()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if ( vehicle ) then
		paralyzeAndRepairCar(vehicle, true)
	end
end

function bindConfigResetKeys(player)
  -- outputChatBox("bindConfigResetKeys")
    bindKey ( "R", "up", manualRepair )
end

function unbindConfigResetKeys(player)
    unbindKey ( "F3" )
end

function onJoinForResetKeys ( )
    bindConfigResetKeys(source)
end
addEventHandler("onPlayerJoin", getRootElement(), onJoinForResetKeys)

  --unbind on quit
function onQuitForResetKeys ( )
    unbindConfigResetKeys(source)
end
addEventHandler("onPlayerQuit", getRootElement(), onQuitForResetKeys)

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
    bindConfigResetKeys(source)
end)

setTimer(function()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if ( vehicle ) then
		local rx, ry, rz = getElementRotation(vehicle)
		if (rx > 90 and rx < 270) or (ry > 90 and ry < 270) then
			addEventHandler("onClientRender", root, drawFlipMessage)
		else
			removeEventHandler("onClientRender", root, drawFlipMessage)
		end
	end
end, 1000, 0)

function drawFlipMessage()
	dxDrawText("Press 'R' to flip your vehicle!", 0, screenH * 0.3, screenW, screenH, tocolor(255, 255, 255, 255), 2, "default-bold", "center", "top")
end
