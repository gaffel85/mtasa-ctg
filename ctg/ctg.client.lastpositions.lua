local transforms = {}

function storeTransform()
	local player = localPlayer
	local vehicle = getPedOccupiedVehicle(player)
	if (not vehicle) then
		return
	end
	local x, y, z = getElementPosition(vehicle)
	local rx, ry, rz = getElementRotation(vehicle)
	local vx, vy, vz = getElementVelocity(vehicle)
	local vrx, vry, vrz = getElementAngularVelocity(vehicle)
	local transform = {
		x = x,
		y = y,
		z = z,
		rx = rx,
		ry = ry,
		rz = rz,
		vx = vx,
		vy = vy,
		vz = vz,
		vrx = vrx,
		vry = vry,
		vrz = vrz
	}
	table.insert(transforms, transform)
	if (#transforms > 5) then
		table.remove(transforms, 1)
	end
end
--setTimer(storeTransform, 3000, 0)

-- listen for the report last transform event called reportLastTransform

