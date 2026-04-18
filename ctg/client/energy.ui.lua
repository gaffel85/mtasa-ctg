
local DGS = exports.dgs
local screenW, screenH = guiGetScreenSize()

-- Intermediate size (25% screen height)
local HUD_SIZE = screenH * 0.25
local MARGIN = 45
local HUD_X = screenW - HUD_SIZE - MARGIN
local HUD_Y = screenH - HUD_SIZE - MARGIN

local COLOR_CYAN = {0/255, 255/255, 255/255, 1}
local COLOR_AMBER = {255/255, 191/255, 0/255, 1}
local BG_ALPHA = 0.6 

local PI = math.pi
-- Angles in radians
local START_ANGLE = 135 * (PI / 180)
local TOTAL_ANGLE = 270 * (PI / 180)

local hud = {
    cyanShader = nil,
    amberShader = nil,
    valveShader = nil,
    liquidShader = nil,
    reliefShader = nil,
    container = nil,
    
    energy = 0,
    overcharge = 0,
    valveProgress = 0,
    
    -- Nitro UI
    nitroKeyBg = nil,
    nitroKeyLabel = nil,
    nitroAbilityLabel = nil,
    
    -- Jump UI
    jumpKeyBg = nil,
    jumpKeyLabel = nil,
    jumpAbilityLabel = nil,
    
    canonButton = nil,
    canonKeyIcon = nil,
    canonKeyLabel = nil,
}

local function createArcShader(color, inner, outer, freq1, freq2, totalAngle)
    local shader = dxCreateShader("client/hud_arc.fx")
    if shader then
        dxSetShaderValue(shader, "color", color)
        dxSetShaderValue(shader, "innerRadius", inner)
        dxSetShaderValue(shader, "outerRadius", outer)
        dxSetShaderValue(shader, "startAngle", START_ANGLE)
        dxSetShaderValue(shader, "totalAngle", totalAngle or TOTAL_ANGLE)
        dxSetShaderValue(shader, "progress", 0)
        dxSetShaderValue(shader, "bgAlpha", BG_ALPHA)
        dxSetShaderValue(shader, "Time", 0)
        dxSetShaderValue(shader, "Freq1", freq1 or 12.0)
        dxSetShaderValue(shader, "Freq2", freq2 or 25.0)
    end
    return shader
end

local function createKeyVisual(x, y, keyText, abilityText, container)
    local keyWidth = 0.18
    local keyHeight = 0.11
    local spacing = 0.04
    local totalWidth = keyWidth + spacing + 0.25
    local startX = 0.5 - totalWidth / 2
    local rndRect = DGS:dgsCreateRoundRect(0.2, true, tocolor(40, 40, 40, 255))
    local keyBg = DGS:dgsCreateImage(startX, y, keyWidth, keyHeight, rndRect, true, container)
    local keyLabel = DGS:dgsCreateLabel(0, 0, 1, 1, keyText, true, keyBg)
    DGS:dgsSetProperty(keyLabel, "alignment", {"center", "center"})
    DGS:dgsSetProperty(keyLabel, "font", "default-bold")
    local abilityLabel = DGS:dgsCreateLabel(startX + keyWidth + spacing, y, 0.4, keyHeight, abilityText, true, container)
    DGS:dgsSetProperty(abilityLabel, "alignment", {"left", "center"})
    DGS:dgsSetProperty(abilityLabel, "font", "default-bold")
    DGS:dgsSetProperty(abilityLabel, "textColor", tocolor(0, 255, 255, 255))
    DGS:dgsSetProperty(abilityLabel, "textSize", {1.1, 1.1})
    return keyBg, keyLabel, abilityLabel
end

local function initHud()
    local components = {"area_name", "radio", "vehicle_name"}
    for _, component in ipairs(components) do
        setPlayerHudComponentVisible(component, false)
    end

    local innerMin, innerMax = 0.32, 0.42
    local outerMin, outerMax = 0.43, 0.48
    hud.cyanShader = createArcShader(COLOR_CYAN, innerMin, innerMax, 8.0, 18.0, 256 * (PI / 180))
    hud.amberShader = createArcShader(COLOR_AMBER, outerMin, outerMax, 12.0, 25.0, TOTAL_ANGLE)
    
    local ventDiameter = outerMax - innerMin
    local ventRadius = ventDiameter / 2
    local ventCenterDist = (innerMin + outerMax) / 2
    
    hud.valveShader = dxCreateShader("client/hud_vent.fx")
    if hud.valveShader then
        dxSetShaderValue(hud.valveShader, "color1", COLOR_CYAN)
        dxSetShaderValue(hud.valveShader, "color2", COLOR_AMBER)
        dxSetShaderValue(hud.valveShader, "progress", 0)
        dxSetShaderValue(hud.valveShader, "bgAlpha", BG_ALPHA)
        dxSetShaderValue(hud.valveShader, "startInner", 0.02)
        dxSetShaderValue(hud.valveShader, "startOuter", 0.5)
        dxSetShaderValue(hud.valveShader, "endInner", 0.20)
        dxSetShaderValue(hud.valveShader, "endOuter", 0.5)
        dxSetShaderValue(hud.valveShader, "startAngle", 0)
        dxSetShaderValue(hud.valveShader, "totalAngle", PI)
        dxSetShaderValue(hud.valveShader, "Time", 0)
    end

    hud.liquidShader = dxCreateShader("client/hud_liquid.fx")
    hud.reliefShader = dxCreateShader("client/hud_relief.fx")

    hud.container = DGS:dgsCreateImage(HUD_X, HUD_Y, HUD_SIZE, HUD_SIZE, nil, false)
    DGS:dgsSetProperty(hud.container, "color", tocolor(0, 0, 0, 0))

    DGS:dgsCreateImage(0, 0, 1, 1, hud.cyanShader, true, hud.container)
    DGS:dgsCreateImage(0, 0, 1, 1, hud.amberShader, true, hud.container)
    
    local ventX = 0.5 + ventCenterDist * math.cos(START_ANGLE)
    local ventY = 0.5 + ventCenterDist * math.sin(START_ANGLE)
    local vent = DGS:dgsCreateImage(ventX - ventRadius, ventY - ventRadius, ventDiameter, ventDiameter, hud.valveShader, true, hud.container)
    DGS:dgsSetProperty(vent, "rotation", -45)

    -- Primary Keys
    hud.nitroKeyBg, hud.nitroKeyLabel, hud.nitroAbilityLabel = createKeyVisual(0.5, 0.35, "LMB", "Nitro", hud.container)
    hud.jumpKeyBg, hud.jumpKeyLabel, hud.jumpAbilityLabel = createKeyVisual(0.5, 0.50, "RMB", "Jump", hud.container)

    -- Canon ball button
    local btnW, btnH = 0.35, 0.15
    hud.canonButton = DGS:dgsCreateButton(0.52, 0.82, btnW, btnH, "Canon", true, hud.container)
    DGS:dgsSetProperty(hud.canonButton, "image", hud.liquidShader)
    DGS:dgsSetProperty(hud.canonButton, "textColor", tocolor(255, 191, 0, 255))
    DGS:dgsSetProperty(hud.canonButton, "font", "default-bold")
    DGS:dgsSetProperty(hud.canonButton, "alignment", {"right", "center"})
    DGS:dgsSetProperty(hud.canonButton, "padding", {50, 0})

    if hud.liquidShader then
        dxSetShaderValue(hud.liquidShader, "size", {btnW * HUD_SIZE, btnH * HUD_SIZE})
        dxSetShaderValue(hud.liquidShader, "radius", 8.0)
        dxSetShaderValue(hud.liquidShader, "color", COLOR_AMBER)
        dxSetShaderValue(hud.liquidShader, "bgAlpha", BG_ALPHA)
    end

    -- Create a square "C" Key Icon using the relief shader
    local keySizePx = btnH * HUD_SIZE * 0.65
    local keyWRel = keySizePx / (btnW * HUD_SIZE)
    local keyHRel = keySizePx / (btnH * HUD_SIZE)
    
    hud.canonKeyIcon = DGS:dgsCreateImage(0.1, 0.5 - keyHRel/2, keyWRel, keyHRel, hud.reliefShader, true, hud.canonButton)
    hud.canonKeyLabel = DGS:dgsCreateLabel(0, 0, 1, 1, "C", true, hud.canonKeyIcon)
    DGS:dgsSetProperty(hud.canonKeyLabel, "alignment", {"center", "center"})
    DGS:dgsSetProperty(hud.canonKeyLabel, "font", "default-bold")
    DGS:dgsSetProperty(hud.canonKeyLabel, "textColor", tocolor(255, 255, 255, 255))

    if hud.reliefShader then
        dxSetShaderValue(hud.reliefShader, "size", {keySizePx, keySizePx})
        dxSetShaderValue(hud.reliefShader, "radius", 5.0)
        dxSetShaderValue(hud.reliefShader, "thickness", 2.0)
        -- Using a muted amber-gray for better integration
        dxSetShaderValue(hud.reliefShader, "color", {0.6, 0.5, 0.3, 0.8})
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    initHud()
end)

local function updateHudVisuals()
    local time = getTickCount() / 1000
    local energyState = getClientState("energy")
    if energyState and energyState.isBurning then
        hud.valveProgress = math.min(1, hud.valveProgress + 0.1)
    else
        hud.valveProgress = math.max(0, hud.valveProgress - 0.1)
    end

    if hud.cyanShader then 
        dxSetShaderValue(hud.cyanShader, "progress", hud.energy) 
        dxSetShaderValue(hud.cyanShader, "Time", time)
    end
    if hud.amberShader then 
        dxSetShaderValue(hud.amberShader, "progress", hud.overcharge) 
        dxSetShaderValue(hud.amberShader, "Time", time)
    end
    if hud.valveShader then 
        dxSetShaderValue(hud.valveShader, "progress", hud.valveProgress) 
        dxSetShaderValue(hud.valveShader, "Time", time)
    end
    if hud.liquidShader then
        dxSetShaderValue(hud.liquidShader, "progress", hud.overcharge >= 1 and 1 or 0)
        dxSetShaderValue(hud.liquidShader, "Time", time)
    end

    if hud.overcharge >= 1 then
        DGS:dgsSetProperty(hud.canonButton, "textColor", tocolor(0, 0, 0, 255))
        DGS:dgsSetProperty(hud.canonKeyLabel, "textColor", tocolor(0, 0, 0, 255))
        if hud.reliefShader then dxSetShaderValue(hud.reliefShader, "color", {0.0, 0.0, 0.0, 0.9}) end
    else
        DGS:dgsSetProperty(hud.canonButton, "textColor", tocolor(255, 191, 0, 180))
        DGS:dgsSetProperty(hud.canonKeyLabel, "textColor", tocolor(200, 200, 200, 100))
        if hud.reliefShader then dxSetShaderValue(hud.reliefShader, "color", {0.4, 0.3, 0.2, 0.3}) end
    end
end

addEventHandler("onClientRender", root, updateHudVisuals)

function setEnergyBarProgress(percentage) hud.energy = percentage / 100 end
function setOverChargeBarProgress(percentage) hud.overcharge = percentage / 100 end

function setPowerEnabled(powerKey, enabled)
    local alpha = enabled and 255 or 100
    if powerKey == "nitro" then
        DGS:dgsSetProperty(hud.nitroKeyBg, "alpha", alpha / 255)
        DGS:dgsSetProperty(hud.nitroKeyLabel, "alpha", alpha / 255)
        DGS:dgsSetProperty(hud.nitroAbilityLabel, "alpha", alpha / 255)
    elseif powerKey == "jump" then
        DGS:dgsSetProperty(hud.jumpKeyBg, "alpha", alpha / 255)
        DGS:dgsSetProperty(hud.jumpKeyLabel, "alpha", alpha / 255)
        DGS:dgsSetProperty(hud.jumpAbilityLabel, "alpha", alpha / 255)
    end
end

function setNitroEnabled(enabled) setPowerEnabled("nitro", enabled) end
function setJumpEnabled(enabled) setPowerEnabled("jump", enabled) end
function setCanonEnabled(enabled) end
