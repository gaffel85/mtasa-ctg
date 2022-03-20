local bombMarker
local bombObj

local DEFAULT_OFFSET = { x = 0, y = 0, z = 0}
local DEFAULT_ROTATION = { x = 45, y = 90, z = 0}
local DEFAULT_SCALE = 3

local vehicleParams = { 
	[551] = { 
		name = "", 
		bomb = {
			offset = { x = 0, y = -1.5, z = 0.7},
			rotation = { x = 45, y = 90, z = 0},
			scale = 3
		 } 
	}, 
	[415] = {  
		name = "", 
		bomb = {
			offset = { x = 0, y = 0, z = 1},
			rotation = { x = 45, y = 90, z = 0},
			scale = 2
		 } 
	}, 
	[531] = { 
		name = "", 
		bomb = {
			offset = { x = 0, y = 0, z = 1},
			rotation = { x = 45, y = 90, z = 0},
			scale = 2
		 } 
	 }, 
	[475] = {  
		name = "", 
		bomb = {
			offset = { x = 0, y = 0, z = 2},
			rotation = { x = 45, y = 90, z = 0},
			scale = 2
		 } 
	}, 
	[437] = {  
		name = "", 
		bomb = {
			offset = { x = 0, y = 0, z = 1},
			rotation = { x = 45, y = 90, z = 0},
			scale = 2
		 } 
	}, 
	[557] = {  
		name = "", 
		bomb = {
			offset = { x = 0, y = 0, z = 1},
			rotation = { x = 45, y = 90, z = 0},
			scale = 2
		 } 
	}
}

function getBombParams ( vehicle )
	local model = getElementModel ( vehicle )
	local params = vehicleParams[model]
	if ( params ~= nil ) then
		local bomb = params.bomb
		return bomb.offset.x, bomb.offset.y, bomb.offset.z, bomb.rotation.x, bomb.rotation.y, bomb.rotation.z, bomb.scale
	else 
		return DEFAULT_OFFSET.x, DEFAULT_OFFSET.y, DEFAULT_OFFSET.z,DEFAULT_ROTATION.x, DEFAULT_ROTATION.y, DEFAULT_ROTATION.z, DEFAULT_SCALE
	end
end

function attachBombMarker ( player )
	if(bombMarker == nil ) then
		bombMarker = createMarker ( 0, 0, 1, "arrow", 2.0, 255, 0, 0)
	end
	attachElements ( bombMarker, player, 0, 0, 4 )

	local vehicle = getPedOccupiedVehicle ( player )
	local x,y,z,rx,ry,rz,scale = getBombParams ( vehicle )
	if ( bombObj == nil ) then
		bombObj = createObject( 1654, 0, 0, 0, 0, 0, 0, true )
		setObjectScale ( bombObj, scale )
		setElementCollisionsEnabled ( bombObj, false )
	end
	attachElements ( bombObj, vehicle, x, y, z, rx,ry,rz )
end

function hideBombMarker ( exceptPlayer )
	setElementVisibleTo(bombMarker, root, false)
	if ( exceptPlayer ~= nil ) then
		setElementVisibleTo(bombMarker, exceptPlayer, true)
	end
end

function showBombMarker ( exceptPlayer )
	setElementVisibleTo(bombMarker, root, true)
	if ( exceptPlayer ~= nil ) then
		setElementVisibleTo(bombMarker, exceptPlayer, false)
	end
end

function resetBombMarker ()
	if (bombMarker ~= nil) then
		destroyElement(bombMarker)
		bombMarker = nil
	end 

	if ( bombObj ~= nil ) then
		destroyElement ( bombObj )
		bombObj = nil
	end
end