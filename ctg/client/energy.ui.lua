DGS = exports.dgs --shorten the export function prefix

local energyUi = {
    bar = nil,
    nitroButton = nil,
    nitroLabel = nil,
    jumpButton = nil,
    jumpLabel = nil,
}

local overchargeUi = {
    bar = nil,
    canonButton = nil,
    canonLabel = nil,
}

local startX = 0.88
local labelX = 0.92

local function createEnergyBar()
    return guiCreateProgressBar( startX, 0.5, 0.1, 0.04, true, nil ) --create the gui-progressbar
end

local function createOverChargeBar()
    overchargeBar = DGS:dgsCreateProgressBar(startX, 0.55, 0.1, 0.04, true, nil)
    --overchargeBar = DGS:dgsCreateProgressBar(0.8, 0.5, 0.3, 0.3, true, nil)
    --DGS:dgsProgressBarSetStyle(overchargeBar,"ring-round",{
    --    isClockwise = true,
    --    rotation = 90,
    --    antiAliased = 0.005,
    --    radius = 0.2,
    --    thickness = 0.05
    --})
    return overchargeBar
end

local function createText(x, y, width, height, text)
    local label = guiCreateLabel(x, y, width, height, text, true, nil)
    guiLabelSetHorizontalAlign(label, "left")
    guiLabelSetVerticalAlign(label, "center")
    return label
end

local function createKeyButton(x, y, text)
    local button = guiCreateButton(x, y, 0.03, 0.04, text, true, nil)
    guiLabelSetHorizontalAlign(button, "left")
    guiLabelSetVerticalAlign(button, "center")
    return button
end

local function createNitroUi()
    local button = createKeyButton(startX, 0.4, "LMB")
    local label = createText(labelX, 0.4, 0.1, 0.04, "Nitro")
    return button, label
end

local function createJumpUi()
    local button = createKeyButton(startX, 0.45, "RMB")
    local label = createText(labelX, 0.45, 0.1, 0.04, "Jump")
    return button, label
end

local function createCanonUi()
    local button = createKeyButton(startX, 0.6, "C")
    local label = createText(labelX, 0.6, 0.1, 0.04, "Canon ball")
    return button, label
end

local function getEnergyUi()
    if energyUi.bar == nil then
        local nitroButton, nitroLabel = createNitroUi()
        local jumpButton, jumpLabel = createJumpUi()
        energyUi.bar = createEnergyBar()
        energyUi.nitroButton = nitroButton
        energyUi.nitroLabel = nitroLabel
        energyUi.jumpButton = jumpButton
        energyUi.jumpLabel = jumpLabel
    end
    return energyUi
end

local function getOverchargeUi()
    if overchargeUi.bar == nil then
        local canonButton, canonLabel = createCanonUi()
        overchargeUi.bar = createOverChargeBar()
        overchargeUi.button = canonButton
        overchargeUi.label = canonLabel
    end
    return overchargeUi
end

function setEnergyBarProgress(percentage)   
    local energyBar = getEnergyUi().bar
    guiProgressBarSetProgress(energyBar, percentage)
end

function setOverChargeBarProgress(percentage)
    local overchargeBar = getOverchargeUi().bar
    DGS:dgsProgressBarSetProgress(overchargeBar, percentage)
end

local function setPowerEnabled(ui, enabled)
    if enabled then
        guiSetAlpha(ui.button, 1)
        guiSetAlpha(ui.label, 1)
        guiSetText(ui.label, "Nitro")
    else
        guiSetAlpha(ui.button, 0.5)
        guiSetAlpha(ui.label, 0.5)
        guiSetText(ui.label, "Not enough energy")
    end
end

function setNitroEnabled(enabled)
    setPowerEnabled(getEnergyUi(), enabled)
end