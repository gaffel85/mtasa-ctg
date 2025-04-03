local energyBar = nil
local overchargeBar = nil

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

local function createEnergyBar()
    energyBar = guiCreateProgressBar( 0.8, 0.5, 0.1, 0.04, true, nil ) --create the gui-progressbar
end

local function createOverChargeBar()
    -- overchargeBar = DGS:dgsCreateProgressBar(0.8, 0.55, 0.1, 0.04, true, nil)
    overchargeBar = DGS:dgsCreateProgressBar(0.8, 0.5, 0.3, 0.3, true, nil)
    DGS:dgsProgressBarSetStyle(overchargeBar,"ring-round",{
        isClockwise = true,
        rotation = 90,
        antiAliased = 0.005,
        radius = 0.2,
        thickness = 0.05
    })
end

local function createText(x, y, width, height, text)
    local label = guiCreateLabel(x, y, width, height, text, true, nil)
    guiLabelSetHorizontalAlign(label, "left")
    guiLabelSetVerticalAlign(label, "center")
    return label
end

local function createNitroUi()
    local button = guiCreateButton(0.8, 0.42, 0.1, 0.04, "LMB", true, nil)
    local label = createText(0.8, 0.42, 0.1, 0.04, "LMB")
    return button, label
end

local function createJumpUi()
    local button = guiCreateButton(0.8, 0.45, 0.1, 0.04, "RMB", true, nil)
    local label = createText(0.8, 0.45, 0.1, 0.04, "RMB")
    return button, label
end

local function createCanonUi()
    local button = guiCreateButton(0.8, 0.65, 0.1, 0.04, "C", true, nil)
    local label = createText(0.8, 0.65, 0.1, 0.04, "Canon ball")
    return button, label
end

local function getEnergyUi()
    if energyUi.bar == nil then
        local nitroButton, nitroLabel = createNitroUi()
        local jumpButton, jumpLabel = createJumpUi()
        energyUi.bar = getEnergyBar()
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

function setNitroEnabled(enabled)
    local energyUi = getEnergyUi()
    guiSetAlpha(energyUi.nitroButton, 1)
    guiSetAlpha(energyUi.nitroLabel, 1)
    guiSetText(energyUi.nitroButton, "LMB")
end