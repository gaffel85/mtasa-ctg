-- ctg/client/gold.tether.lua
local beamShader = nil
local beamTexture = nil
local goldObjects = {}
local MAX_GOLD_OBJECTS = 6
local lastStealAttempt = 0
local STEAL_COOLDOWN = 500
local beamGoldFallTime = 3000

addEventHandler("onClientResourceStart", resourceRoot, function()
    beamShader = dxCreateShader("gold_beam.fx")
    beamTexture = dxCreateTexture("img/powerbeam.png")
    if beamShader and beamTexture then
        dxSetShaderValue(beamShader, "gTexture", beamTexture)
    end

    -- Pre-create gold object pool
    for i = 1, MAX_GOLD_OBJECTS do
        local obj = createObject(1212, 0, 0, 0)
        setElementCollisionsEnabled(obj, false)
        setElementAlpha(obj, 180)
        setElementDimension(obj, getElementDimension(localPlayer))
        setElementInterior(obj, getElementInterior(localPlayer))
        setElementData(obj, "tether_progression", (i-1) / MAX_GOLD_OBJECTS)
        setElementData(obj, "tether_rotation", math.random(0, 360))
        setElementStreamable(obj, false)
        setElementPosition(obj, 0, 0, -100) -- Hide initially
        goldObjects[i] = obj
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    for _, obj in ipairs(goldObjects) do
        if isElement(obj) then destroyElement(obj) end
    end
end)

addEventHandler("onClientRender", root, function()
    local carrier = getGoldCarrier()
    if not carrier or not isElement(carrier) then 
        hideGoldObjects()
        return 
    end

    local isJumping = getElementData(carrier, "isCarrierUsingJumpAbility")
    if not isJumping then 
        hideGoldObjects()
        return 
    end

    local vehicle = getPedOccupiedVehicle(carrier)
    if not vehicle then 
        hideGoldObjects()
        return 
    end

    -- 1. Get Beam Positions
    local cx, cy, cz = getElementPosition(vehicle)
    local startX, startY, startZ = cx, cy, cz - 0.5
    
    local hit, hX, hY, hZ = processLineOfSight(startX, startY, startZ, startX, startY, startZ - 50, true, true, false, true, false, true, false, nil, vehicle)
    if not hit then
        hX, hY, hZ = startX, startY, startZ - 50
    end

    -- 2. Draw Beam (Procedural Cylinder)
    local segments = 10
    local radius = 1.0
    local vertices = {}
    local color = tocolor(10, 120, 255, 100) -- Golden, semi-transparent
    
    for i = 0, segments do
        local angle = (i / segments) * math.pi * 2
        local dx = math.cos(angle) * radius
        local dy = math.sin(angle) * radius
        
        -- Add top vertex {x, y, z, color}
        table.insert(vertices, {startX + dx, startY + dy, startZ, color})
        -- Add bottom vertex {x, y, z, color}
        table.insert(vertices, {hX + dx, hY + dy, hZ, color})
    end
    
    -- Draw the cylinder walls as a solid primitive with the correct stage
    dxDrawPrimitive3D("trianglestrip", "prefx", unpack(vertices))

    -- 3. Animate Gold Objects
    local timeDelta = getTickCount() - (lastTick or getTickCount())
    lastTick = getTickCount()
    
    for _, obj in ipairs(goldObjects) do
        local prog = getElementData(obj, "tether_progression") or 0
        local rot = getElementData(obj, "tether_rotation") or 0
        
        prog = prog + (timeDelta / beamGoldFallTime) -- Complete fall in 1.5s
        if prog > 1.0 then prog = 0 end
        rot = (rot + timeDelta * 0.2) % 360
        
        setElementData(obj, "tether_progression", prog, false)
        setElementData(obj, "tether_rotation", rot, false)
        
        local ox = startX + (hX - startX) * prog
        local oy = startY + (hY - startY) * prog
        local oz = startZ + (hZ - startZ) * prog
        
        setElementPosition(obj, ox, oy, oz)
        setElementRotation(obj, 0, 0, rot)
        setObjectScale(obj, 1.5)
    end

    -- 4. Steal Detection (for local player as chaser)
    if carrier ~= localPlayer then
        local myVehicle = getPedOccupiedVehicle(localPlayer)
        if myVehicle then
            local mx, my, mz = getElementPosition(myVehicle)
            local dist2D = getDistanceBetweenPoints2D(mx, my, cx, cy)
            
            if dist2D <= 3.5 and mz < cz then
                local now = getTickCount()
                if now - lastStealAttempt > STEAL_COOLDOWN then
                    lastStealAttempt = now
                    triggerServerEvent("onRequestGoldSteal", localPlayer)
                end
            end
        end
    end
end)

function hideGoldObjects()
    for _, obj in ipairs(goldObjects) do
        if isElement(obj) then
            setElementPosition(obj, 0, 0, -100)
        end
    end
end
