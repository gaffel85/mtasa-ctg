local DGS = nil

local warningInterface = nil
local warningImage = nil
local warningLabel = nil
local currentAlpha = 0
local targetAlpha = 0
local fadeSpeed = 0.05 -- Speed per frame

local function getVehicleSpeed(vehicle)
    if not vehicle then return 0 end
    local vx, vy, vz = getElementVelocity(vehicle)
    return math.sqrt(vx^2 + vy^2 + vz^2) * 180
end

local function createWarningUI()
    if warningInterface then return end
    if not DGS then DGS = exports.dgs end
    if not DGS then return end
    
    -- 4x4 meters in world, 800x800 resolution for better text clarity
    warningInterface = DGS:dgsCreate3DInterface(0, 0, 0, 4, 4, 800, 800)
    DGS:dgsSetProperty(warningInterface, "maxDistance", MomentumConfig.WarningDistance)
    DGS:dgsSetProperty(warningInterface, "faceTo", "camera")
    
    -- Image occupies top half
    warningImage = DGS:dgsCreateImage(200, 0, 400, 400, "img/forbidden.png", false, warningInterface)
    
    -- Bolder, larger text with shadow
    warningLabel = DGS:dgsCreateLabel(0, 420, 800, 100, "Too low speed", false, warningInterface)
    DGS:dgsSetProperty(warningLabel, "alignment", {"center", "top"})
    DGS:dgsSetProperty(warningLabel, "color", tocolor(255, 0, 0, 255))
    DGS:dgsSetProperty(warningLabel, "textSize", {8.5, 8.5}) -- Made much bigger
    DGS:dgsSetProperty(warningLabel, "font", "default-bold") -- Set to bold
    
    -- Add shadow
    DGS:dgsSetProperty(warningLabel, "shadow", {4, 4, tocolor(0, 0, 0, 255)})
    
    DGS:dgsSetVisible(warningInterface, false)
    DGS:dgsSetAlpha(warningInterface, 0)
end

addEventHandler("onClientRender", root, function()
    if not DGS then 
        DGS = exports.dgs
        if not DGS then return end
    end

    local goldCarrier = getGoldCarrier()
    local carrierVehicle = goldCarrier and getPedOccupiedVehicle(goldCarrier)
    local localVehicle = getPedOccupiedVehicle(localPlayer)
    
    local shouldShow = false
    local cx, cy, cz = 0, 0, 0

    if goldCarrier and goldCarrier ~= localPlayer and carrierVehicle and localVehicle then
        cx, cy, cz = getElementPosition(carrierVehicle)
        local lx, ly, lz = getElementPosition(localVehicle)
        
        -- Distance check first
        local distSq = (cx-lx)^2 + (cy-ly)^2 + (cz-lz)^2
        if distSq <= MomentumConfig.WarningDistance^2 then
            local localSpeed = getVehicleSpeed(localVehicle)
            local carrierSpeed = getVehicleSpeed(carrierVehicle)

            -- Rule 1: > MomentumConfig.Rule1MinSpeed km/h
            -- Rule 2: > Carrier Speed + MomentumConfig.Rule2RelativeSpeed km/h
            local rule1 = localSpeed > MomentumConfig.Rule1MinSpeed
            local rule2 = localSpeed > (carrierSpeed + MomentumConfig.Rule2RelativeSpeed)

            if not rule1 and not rule2 then
                shouldShow = true
            end
        end
    end

    -- Update target alpha
    targetAlpha = shouldShow and 1 or 0

    -- Handle fading
    if currentAlpha ~= targetAlpha then
        if currentAlpha < targetAlpha then
            currentAlpha = math.min(currentAlpha + fadeSpeed, targetAlpha)
        else
            currentAlpha = math.max(currentAlpha - fadeSpeed, targetAlpha)
        end

        if not warningInterface and currentAlpha > 0 then
            createWarningUI()
        end

        if warningInterface then
            if currentAlpha <= 0 then
                DGS:dgsSetVisible(warningInterface, false)
            else
                DGS:dgsSetVisible(warningInterface, true)
                DGS:dgsSetAlpha(warningInterface, currentAlpha)
            end
        end
    end

    -- Update position if visible
    if warningInterface and currentAlpha > 0 and carrierVehicle then
        -- Refresh position in case vehicle moved
        cx, cy, cz = getElementPosition(carrierVehicle)
        DGS:dgsSetProperty(warningInterface, "position", {cx, cy, cz + 1.5})
    end
end)
