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

-- 2D HUD Warning logic for stationary blockers
local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()

local function getOpponentHideoutPos()
    local myTeam = getPlayerTeam(localPlayer)
    local teams = getElementsByType("team")
    
    -- If teams are active, find the other team's hideout
    for _, team in ipairs(teams) do
        if team ~= myTeam then
            local hideout = getHideoutData(team)
            if hideout and hideout.pos then
                return hideout.pos.x, hideout.pos.y, hideout.pos.z
            end
        end
    end
    
    -- Fallback for no teams or single team: use the first hideout found
    if #teams > 0 then
        local hideout = getHideoutData(teams[1])
        if hideout and hideout.pos then
            return hideout.pos.x, hideout.pos.y, hideout.pos.z
        end
    end
    
    return nil
end

addEventHandler("onClientRender", root, function()
    local localVehicle = getPedOccupiedVehicle(localPlayer)
    if not localVehicle then return end
    
    local goldCarrier = getGoldCarrier()
    if goldCarrier == localPlayer then return end -- No warning for the carrier
    
    local localSpeed = getVehicleSpeed(localVehicle)
    if localSpeed >= MomentumConfig.HUDWarningMinSpeed then return end
    
    -- 1. Draw the "Always-on" text when slow
    local text = "Can't steal gold with too low speed"
    local textY = SCREEN_HEIGHT * 0.7
    dxDrawText(text, 2, textY + 2, SCREEN_WIDTH + 2, textY + 52, tocolor(0, 0, 0, 200), 2.0, "default-bold", "center", "center") -- Shadow
    dxDrawText(text, 0, textY, SCREEN_WIDTH, textY + 50, tocolor(255, 20, 20, 255), 2.0, "default-bold", "center", "center")
    
    -- 2. Proximity check for pulsating icon
    local lx, ly, lz = getElementPosition(localVehicle)
    local minDist = 9999
    
    -- Check distance to Carrier
    if goldCarrier then
        local cv = getPedOccupiedVehicle(goldCarrier)
        if cv then
            local cx, cy, cz = getElementPosition(cv)
            local dist = getDistanceBetweenPoints3D(lx, ly, lz, cx, cy, cz)
            if dist < minDist then minDist = dist end
        end
    end
    
    -- Check distance to Opponent Hideout
    local hx, hy, hz = getOpponentHideoutPos()
    if hx then
        local dist = getDistanceBetweenPoints3D(lx, ly, lz, hx, hy, hz)
        if dist < minDist then minDist = dist end
    end
    
    -- Pulsating icon if close to either
    if minDist < MomentumConfig.HUDWarningDistance then
        local distFactor = 1 - (minDist / MomentumConfig.HUDWarningDistance) -- 0 to 1
        
        -- Frequency increases as we get closer (pulse speed 1.0 to 4.0 Hz approx)
        local pulseFreq = 1.0 + (distFactor * 3.0)
        local time = getTickCount() / 1000
        local alphaMultiplier = 0.5 + 0.5 * math.sin(time * math.pi * 2 * pulseFreq)
        
        local iconSize = 64 + 32 * distFactor
        local iconX = (SCREEN_WIDTH - iconSize) / 2
        local iconY = textY - iconSize - 10
        
        dxDrawImage(iconX, iconY, iconSize, iconSize, "img/forbidden.png", 0, 0, 0, tocolor(255, 0, 0, alphaMultiplier * 255))
    end
end)
