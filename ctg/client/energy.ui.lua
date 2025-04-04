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
    local rndRect = DGS:dgsCreateRoundRect(10,false,tocolor(0,10,20,255))
    
    local button = DGS:dgsCreateButton(270,10,120,60,"Button\nRounded",false)
    DGS:dgsSetProperty(rndRect,"outline",{
        side="in",
        width=5,
        color=tocolor(255,255,225,255),
    })
    
    DGS:dgsSetProperty(button, "image",rndRect)
end

local function createKeyButton(x, y, text)
    local rndRect = DGS:dgsCreateRoundRect(50,true,tocolor(0,0,0,150))  --Create Rounded Rectangle with 50 pixels radius 
    --local image1 = DGS:dgsCreateImage(200,200,400,100,rndRect,false)  --Apply it to the dgs image

    --local dgsButton1 = DGS:dgsCreateButton(x - 0.2, y, 0.03, 0.04, "DGS 1", true, nil, nil, nil, nil, image1)
    --local dgsButton2 = DGS:dgsCreateButton(x - 0.3, y, 0.03, 0.04, "DGS 2", true, nil, nil, nil, nil, rndRect)

    --local line = DGS:dgsCreateLine(x, y, 0.95, 0.3, true)
    --DGS:dgsLineAddItem(line,0,0.1,1,0.3,2,tocolor(0,255,0,255),true)

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

--[[

GUIEditor = {
    button = {},
    window = {},
    edit = {},
    label = {}
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        GUIEditor.window[1] = guiCreateWindow(0.80, 0.29, 0.19, 0.26, "", true)
        guiWindowSetSizable(GUIEditor.window[1], false)

        maxOvercharge = guiCreateRadioButton(0.77, 0.07, 0.04, 0.05, "", true, GUIEditor.window[1])
        jumpEnergy = guiCreateRadioButton(0.90, 0.50, 0.04, 0.05, "", true, GUIEditor.window[1])
        nitroEnergy = guiCreateRadioButton(0.90, 0.77, 0.04, 0.05, "", true, GUIEditor.window[1])
        guiRadioButtonSetSelected(nitroEnergy, true)


        GUIEditor.button[1] = guiCreateButton(0.91, 0.33, 0.03, 0.04, "C", true)


        GUIEditor.button[2] = guiCreateButton(0.91, 0.41, 0.03, 0.04, "shift", true)


        GUIEditor.button[3] = guiCreateButton(0.87, 0.41, 0.03, 0.04, "RMB", true)


        GUIEditor.button[4] = guiCreateButton(0.91, 0.47, 0.03, 0.04, "lctrl", true)


        GUIEditor.button[5] = guiCreateButton(0.87, 0.47, 0.03, 0.04, "LMB", true)


        GUIEditor.label[1] = guiCreateLabel(0.84, 0.35, 0.06, 0.02, "Canon ball", true)
        guiSetFont(GUIEditor.label[1], "clear-normal")
        guiLabelSetHorizontalAlign(GUIEditor.label[1], "right", false)
        guiLabelSetVerticalAlign(GUIEditor.label[1], "center")


        GUIEditor.label[2] = guiCreateLabel(0.90, 0.42, 0.01, 0.02, "/", true)
        guiSetFont(GUIEditor.label[2], "clear-normal")
        guiLabelSetHorizontalAlign(GUIEditor.label[2], "right", false)
        guiLabelSetVerticalAlign(GUIEditor.label[2], "center")


        GUIEditor.label[3] = guiCreateLabel(0.80, 0.42, 0.06, 0.02, "Jump", true)
        guiSetFont(GUIEditor.label[3], "clear-normal")
        guiLabelSetHorizontalAlign(GUIEditor.label[3], "right", false)
        guiLabelSetVerticalAlign(GUIEditor.label[3], "center")


        GUIEditor.label[4] = guiCreateLabel(0.90, 0.49, 0.01, 0.02, "/", true)
        guiSetFont(GUIEditor.label[4], "clear-normal")
        guiLabelSetHorizontalAlign(GUIEditor.label[4], "right", false)
        guiLabelSetVerticalAlign(GUIEditor.label[4], "center")


        GUIEditor.label[5] = guiCreateLabel(0.80, 0.49, 0.06, 0.02, "Nitro", true)
        guiSetFont(GUIEditor.label[5], "clear-normal")
        guiLabelSetHorizontalAlign(GUIEditor.label[5], "right", false)
        guiLabelSetVerticalAlign(GUIEditor.label[5], "center")


        GUIEditor.edit[1] = guiCreateEdit(0.97, 0.31, 0.02, 0.23, "", true)


        GUIEditor.edit[2] = guiCreateEdit(0.94, 0.31, 0.02, 0.23, "", true)    
    end
)

]]--