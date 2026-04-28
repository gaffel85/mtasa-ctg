local screenX, screenY = guiGetScreenSize() -- get the screen resolution (width and height)
local shadowColor = tocolor(0, 0, 0, 255) -- define shadow color outside render scope and use it afterwards (for performance reasons)
local textColor = tocolor(90, 123, 199, 255) -- define color outside render scope and use it afterwards (for performance reasons)
local leaderColor = tocolor(255, 165, 0, 255) -- Orange/Gold for leader
local debugSphere = false

local xLeft = screenX/2 - 100
local yTop = 30
local xRight = screenX/2 + 100
local yBottom = screenY

local xLeft2 = screenX/2 - 100
local yTop2 = 70
local xRight2 = screenX/2 + 100
local yBottom2 = screenY

local function getLeader()
    local carrier = getGoldCarrier()
    if carrier then
        return carrier
    end
    
    local targetX, targetY, targetZ = getPlayerCurrentTargetPos(localPlayer)
    if not targetX then return nil end
    
    local minDistance = math.huge
    local closestPlayer = nil
    for _, player in ipairs(getElementsByType("player")) do
        local x, y, z = getElementPosition(player)
        local dist = getDistanceBetweenPoints3D(x, y, z, targetX, targetY, targetZ)
        if dist < minDistance then
            minDistance = dist
            closestPlayer = player
        end
    end
    return closestPlayer
end
  
function getVehicleSizeData(vehicleId)
    local data = vehicleSizeData[vehicleId]
    return data.radius, data.x, data.y, data.z, data.x2, data.y2, data.z2
end

function distanceMeter()
    -- cgeck distance for all player to target and display
    local targetX, targetY, targetZ = getPlayerCurrentTargetPos(localPlayer)
    if targetX and targetY and targetZ then
        local x, y, z = getElementPosition(localPlayer)
        local distance = getDistanceBetweenPoints3D(x, y, z, targetX, targetY, targetZ)
        distance = math.floor(distance)
        
        --screenX/2 - 200, screenY + 60, screenX/2 + 200, screenY + 120
        dxDrawText(distance.."m", xLeft + 5, yTop + 5, xRight, yBottom, shadowColor, 2.06, "pricedown", "center")
        -- draw zone name text
        dxDrawText(distance.."m", xLeft, yTop, xRight, yBottom, textColor, 2, "pricedown", "center")
    end
end

function showCoords()
    -- 1. Display target coordinates at bottom left with small white font
    local tx, ty, tz = getPlayerCurrentTargetPos(localPlayer)
    if tx then
        local coordText = string.format("(%.0f, %.0f, %.0f)", tx, ty, tz)
        dxDrawText(coordText, 10 + 1, screenY - 25 + 1, screenX, screenY, shadowColor, 1, "default-bold")
        dxDrawText(coordText, 10, screenY - 25, screenX, screenY, tocolor(255, 255, 255, 255), 1, "default-bold")
    end

    -- 2. Display leader name where coordinates were (top centerish)
    local leader = getLeader()
    if leader then
        local leaderName = getPlayerName(leader)
        dxDrawText(leaderName, xLeft2 + 3, yTop2 + 3, xRight2, yBottom2, shadowColor, 2.06, "pricedown", "center")
        dxDrawText(leaderName, xLeft2, yTop2, xRight2, yBottom2, leaderColor, 2, "pricedown", "center")
    end
end

function updateCamera ()
    distanceMeter()
    showCoords()
    --outputChatBox('Hello, world!'..inspect(getElementPosition(localPlayer)))
    for player, active in pairs(getShieldedPlayers()) do
        if active then
            --local player = localPlayer
            local vehicle = getPedOccupiedVehicle(player)
            if not vehicle then
                return
            end
            local x, y, z = getElementPosition(vehicle)
            local minx, miny, minz, maxx, maxy, maxz = getElementBoundingBox(vehicle)
            --local color = tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255))
            local color = tocolor(255, 255, 255, 255)
            --outputChatBox('Hello, world!'..inpect(getElementPosition(localPlayer)))
            
            --find raduis that inclueds all bounding box
            local radius = math.max(maxx - minx, maxy - miny, maxz - minz) / 2
        
            dxDrawWiredSphere(x, y, z, radius, color, 0.5, 2)
        end
    end

    -- draw sphere for all players
    if debugSphere then
        for k, player in ipairs(getElementsByType("player")) do
            local vehicle = getPedOccupiedVehicle(player)
            if not vehicle then
                return
            end
            local x, y, z = getElementPosition(vehicle)
            local radius = getVehicleSizeData(vehicle)
            local minx, miny, minz, maxx, maxy, maxz = getVehicleBoundingBoxData(vehicle)
            local color = tocolor(255, 128, 255, 255)
            dxDrawWiredSphere(x, y, z, radius, color, 0.5, 2)
        end
    end
end
addEventHandler ( "onClientRender", root, updateCamera )