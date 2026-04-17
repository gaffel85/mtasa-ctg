local screenWidth, screenHeight = guiGetScreenSize()
local isVictoryActive = false
local victoryStartTime = 0
local victoryDuration = 5000
local victorySequenceId = 0
local victoryWinner = nil
local enemyVehicles = {}
local desatShader = nil

local sequenceNames = {
    [1] = "The Matrix Freeze",
    [2] = "The Bullet Time",
    [3] = "The Kinetic Shockwave",
    [4] = "The Orbital Strike",
    [5] = "The Automated Getaway"
}

local function getVehicleBoundingBox(winner, enemies)
    local x1, y1, z1 = getElementPosition(winner)
    local minX, minY, minZ = x1, y1, z1
    local maxX, maxY, maxZ = x1, y1, z1
    
    local count = 1
    for _, veh in ipairs(enemies) do
        if isElement(veh) then
            local x, y, z = getElementPosition(veh)
            local dist = getDistanceBetweenPoints3D(x1, y1, z1, x, y, z)
            if dist < 50 then
                minX = math.min(minX, x)
                minY = math.min(minY, y)
                minZ = math.min(minZ, z)
                maxX = math.max(maxX, x)
                maxY = math.max(maxY, y)
                maxZ = math.max(maxZ, z)
                count = count + 1
            end
        end
    end
    
    local centerX = (minX + maxX) / 2
    local centerY = (minY + maxY) / 2
    local centerZ = (minZ + maxZ) / 2
    local radius = getDistanceBetweenPoints3D(minX, minY, minZ, maxX, maxY, maxZ) / 2
    return centerX, centerY, centerZ, math.max(radius, 10)
end

local function getOrbitSpeed()
    local props = getElementData(resourceRoot, "props")
    return (props and props.consts and props.consts.victoryCameraOrbitSpeed) or 1.0
end

local function updateVictoryCamera()
    if not isVictoryActive or not isElement(victoryWinner) then return end
    
    local now = getTickCount()
    local elapsed = now - victoryStartTime
    local progress = math.min(elapsed / victoryDuration, 1.0)
    
    local wx, wy, wz = getElementPosition(victoryWinner)
    local vh = getPedOccupiedVehicle(victoryWinner)
    if vh then
        wx, wy, wz = getElementPosition(vh)
    end

    if victorySequenceId == 1 or victorySequenceId == 2 then -- Orbiting Camera
        local vh = getPedOccupiedVehicle(victoryWinner) or victoryWinner
        local wx, wy, wz = getElementPosition(vh)
        local centerX, centerY, centerZ, radius = getVehicleBoundingBox(vh, enemyVehicles)
        
        local orbitSpeed = getOrbitSpeed()
        local angle = progress * math.pi * 2 * orbitSpeed
        
        -- Smoothly transition the look-at target from the winner to the center of action
        local targetX = wx + (centerX - wx) * progress
        local targetY = wy + (centerY - wy) * progress
        local targetZ = wz + (centerZ - wz) * progress
        
        -- Smoothly transition camera distance (dynamic zoom out)
        local startDist = 12
        local endDist = math.max(radius * 2.5, 20)
        local camDist = startDist + (endDist - startDist) * progress
        
        -- Smoothly transition camera height
        local startHeight = 3
        local endHeight = 15
        local camHeight = startHeight + (endHeight - startHeight) * progress
        
        local cx = targetX + math.cos(angle) * camDist
        local cy = targetY + math.sin(angle) * camDist
        local cz = targetZ + camHeight
        
        setCameraMatrix(cx, cy, cz, targetX, targetY, targetZ)
        
    elseif victorySequenceId == 3 then -- Top-Down Shockwave
        local camHeight = 40
        setCameraMatrix(wx, wy, wz + camHeight, wx, wy, wz)
        
    elseif victorySequenceId == 4 then -- Orbital Strike (Stadium Shot)
        local camDist = 60
        local camHeight = 40
        setCameraMatrix(wx + camDist, wy + camDist, wz + camHeight, wx, wy, wz)
        
    elseif victorySequenceId == 5 then -- Security Camera Tracking
        -- Static position near hideout, looking at winner
        -- We'll use the position where the victory started as the static point
        local staticX = wx - 20
        local staticY = wy - 20
        local staticZ = wz + 10
        setCameraMatrix(staticX, staticY, staticZ, wx, wy, wz)
    end
end

local function renderVictoryTitle()
    if not isVictoryActive then return end
    local name = sequenceNames[victorySequenceId] or "Victory Sequence"
    local scale = 3
    dxDrawText(name, 2, 2, screenWidth + 2, screenHeight / 2 + 2, tocolor(0, 0, 0, 255), scale, "bankgothic", "center", "center", false, false, true, true)
    dxDrawText(name, 0, 0, screenWidth, screenHeight / 2, tocolor(255, 215, 0, 255), scale, "bankgothic", "center", "center", false, false, true, true)
end

addEvent("onClientVictorySequenceStart", true)
addEventHandler("onClientVictorySequenceStart", root, function(winner, sequenceId, duration, enemies)
    isVictoryActive = true
    victoryWinner = winner
    victorySequenceId = sequenceId
    victoryDuration = duration
    victoryStartTime = getTickCount()
    enemyVehicles = enemies or {}
    
    -- Hide HUD
    setPlayerHudComponentVisible("all", false)
    
    if sequenceId == 1 then -- Matrix Freeze
        if not desatShader then
            desatShader = dxCreateShader("desat.fx")
        end
        if desatShader then
            dxSetShaderValue(desatShader, "ScreenSource", dxCreateScreenSource(screenWidth, screenHeight))
            addEventHandler("onClientHUDRender", root, renderDesat)
        end
    end
    
    addEventHandler("onClientPreRender", root, updateVictoryCamera)
    addEventHandler("onClientHUDRender", root, renderVictoryTitle)
    
    setTimer(function()
        stopVictorySequence()
    end, duration, 1)
end)

function renderDesat()
    if desatShader then
        dxUpdateScreenSource(dxGetShaderValue(desatShader, "ScreenSource"))
        dxDrawImage(0, 0, screenWidth, screenHeight, desatShader)
    end
end

function stopVictorySequence()
    if not isVictoryActive then return end
    isVictoryActive = false
    removeEventHandler("onClientPreRender", root, updateVictoryCamera)
    removeEventHandler("onClientHUDRender", root, renderDesat)
    removeEventHandler("onClientHUDRender", root, renderVictoryTitle)
    
    setPlayerHudComponentVisible("all", true)
    setCameraTarget(localPlayer)
end

-- Manual triggers for debugging
for i = 1, 5 do
    bindKey(tostring(i + 4), "down", function()
        triggerServerEvent("requestVictorySequence", resourceRoot, i)
    end)
end
