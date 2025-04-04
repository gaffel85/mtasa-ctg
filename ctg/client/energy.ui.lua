DGS = exports.dgs --shorten the export function prefix

local energyUi = {
    bar = nil,
    nitro = {
        button = nil,
        label = nil,
        defaultText = "Nitro",
    },
    jump = {
        button = nil,
        label = nil,
        defaultText = "Jump",
    },
}

local overchargeUi = {
    bar = nil,
    canon = {
        button = nil,
        label = nil,
        defaultText = "Canon ball",
    },
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

local function testButton()
    local rndRect = DGS:dgsCreateRoundRect(10,false,tocolor(255,255,255,255))
    local button = DGS:dgsCreateButton((270,10,120,60,"Button\nRounded",false)
        :setProperty("image",rndRect))
end

local function createKeyButton(x, y, text)
    local rndRect = DGS:dgsCreateRoundRect(50,true,tocolor(0,0,0,150))  --Create Rounded Rectangle with 50 pixels radius 
    --local image1 = DGS:dgsCreateImage(200,200,400,100,rndRect,false)  --Apply it to the dgs image

    --local dgsButton1 = DGS:dgsCreateButton(x - 0.2, y, 0.03, 0.04, "DGS 1", true, nil, nil, nil, nil, image1)
    --local dgsButton2 = DGS:dgsCreateButton(x - 0.3, y, 0.03, 0.04, "DGS 2", true, nil, nil, nil, nil, rndRect)

    local line = DGS:dgsCreateLine(x, y, 0.95, 0.3, true)
    DGS:dgsLineAddItem(line,0,0.1,1,0.3,2,tocolor(0,255,0,255),true)

    local button = guiCreateButton(x, y, 0.03, 0.04, text, true, nil)
    guiLabelSetHorizontalAlign(button, "left")
    guiLabelSetVerticalAlign(button, "center")
    return button
end

local function createNitroUi()
    local button = createKeyButton(startX, 0.4, "LMB")
    local label = createText(labelX, 0.4, 0.1, 0.04, energyUi.nitro.defaultText)
    return button, label
end

local function createJumpUi()
    local button = createKeyButton(startX, 0.45, "RMB")
    local label = createText(labelX, 0.45, 0.1, 0.04, energyUi.jump.defaultText)
    return button, label
end

local function createCanonUi()
    local button = createKeyButton(startX, 0.6, "C")
    local label = createText(labelX, 0.6, 0.1, 0.04, overchargeUi.canon.defaultText)
    return button, label
end

local function getEnergyUi()
    if energyUi.bar == nil then
        testButton()

        local nitroButton, nitroLabel = createNitroUi()
        local jumpButton, jumpLabel = createJumpUi()
        energyUi.bar = createEnergyBar()
        energyUi.nitro.button = nitroButton
        energyUi.nitro.label = nitroLabel
        energyUi.jump.button = jumpButton
        energyUi.jump.label = jumpLabel
    end
    return energyUi
end

local function getOverchargeUi()
    if overchargeUi.bar == nil then
        local canonButton, canonLabel = createCanonUi()
        overchargeUi.bar = createOverChargeBar()
        overchargeUi.canon.button = canonButton
        overchargeUi.canon.label = canonLabel
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

local function setPowerEnabled(buttonLabelUi, enabled)
    if enabled then
        guiSetAlpha(buttonLabelUi.button, 1)
        guiSetAlpha(buttonLabelUi.label, 1)
        guiSetText(buttonLabelUi.label, buttonLabelUi.defaultText)
    else
        guiSetAlpha(buttonLabelUi.button, 0.5)
        guiSetAlpha(buttonLabelUi.label, 0.5)
        guiSetText(buttonLabelUi.label, "Not enough energy")
    end
end

function setNitroEnabled(enabled)
    setPowerEnabled(getEnergyUi().nitro, enabled)
end

function setJumpEnabled(enabled)
    setPowerEnabled(getEnergyUi().jump, enabled)
end

function setCanonEnabled(enabled)
    setPowerEnabled(getOverchargeUi().canon, enabled)
end