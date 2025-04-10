local damageBar = nil
local damageLabel = nil

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
	local rx,ry,rz = getElementRotation ( vehicle )
	if rx > 90 and rx < 270 or ry > 90 and ry < 270 then
		local posX, posY, posZ = getElementPosition ( vehicle )
		setElementPosition (vehicle, posX, posY, posZ + 2)
		setElementRotation (vehicle, 0, 0, rz)
	end
end

function paralyzeAndRepairCar(vehicle)
	local driver = getVehicleOccupant ( vehicle )
	--if ( driver == getBombHolder() ) then
	--	setVehicleDamageProof ( vehicle , true )
	--	flipIfNeeded ( vehicle )
	--	fixVehicle ( vehicle )
	--	setTimer(function() 
	--		setVehicleDamageProof ( vehicle , false )
	--	end, 5000, 1)
	--else
		--outputDebugString("Reparing car for"..inspect(driver))
	toggleAllControls ( false, true, false )
	setVehicleDamageProof ( vehicle , true )
	triggerServerEvent("clientText", resourceRoot, "showRepairingCar")
	triggerServerEvent("repairCar", resourceRoot, driver)

	fixVehicle (vehicle)
	flipIfNeeded ( vehicle )

	setTimer(function() 
		toggleAllControls ( true, true, true )
		setVehicleDamageProof ( vehicle , false )
	end, getConst().repairTime * 1000, 1)
end

addEventHandler ( "onClientVehicleDamage", root, function ( attacker, weapon, loss )

	if ( getVehicleOccupant ( source ) ~= localPlayer ) then
		--outputDebugString("Not my vehicle"..inspect(source))
		return
	end	

	if (damageBar == nil) then
		damageBar = guiCreateProgressBar( 0.8, 0.3, 0.1, 0.03, true, nil ) --create the gui-progressbar
		damageLabel = guiCreateLabel( 0, 0,1,1,"Damage",true, damageBar)
		guiLabelSetColor ( damageLabel, 255, 0, 0 )
		guiLabelSetHorizontalAlign ( damageLabel, "center" )
		guiLabelSetVerticalAlign ( damageLabel, "center" )
		guiSetFont(damageLabel, "default-bold-small")
	end

	local vehicle = source
	local health = getElementHealth ( vehicle )
	guiProgressBarSetProgress(damageBar, 100 * (math.max(health, 250) - 250) / 750)
	if ( health < 250 ) then
		paralyzeAndRepairCar(vehicle)
	end
end )

function manualRepair()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if ( vehicle ) then
		local posX, posY, posZ = getElementPosition ( vehicle )
		setElementPosition (vehicle, posX, posY, posZ + 2)
		setElementRotation (vehicle, 0, 0, rz)
		paralyzeAndRepairCar(vehicle)
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
		if isElementOnFire ( vehicle ) then
			outputChatBox("Vehicle is on fire")
			paralyzeAndRepairCar()
		end
	end
end, 3000, 1)



