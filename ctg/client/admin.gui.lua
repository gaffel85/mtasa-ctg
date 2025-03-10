local adminWindow = nil
local constTab = nil
local powerTab = nil
local playerTab = nil
local controlTab = nil
local saveButton = nil
local closeButton = nil

local constRows = {}

local localConsts = nil

GUIEditor = {
    tab = {},
    window = {},
    edit = {},
    label = {}
}

function toggleWindow()
    if (adminWindow == nil) then
        createWindow()
    end
    if guiGetVisible(adminWindow) then
        guiSetVisible(adminWindow, false)
        guiSetInputEnabled(false)
        showCursor(false)
    else
        guiSetVisible(adminWindow, true)
        guiSetInputEnabled(true)
        showCursor(true)
    end
end

function getConst()
    localConsts = getElementData(resourceRoot, "props")
    return localConsts
end

function saveConsts()
    setElementData(resourceRoot, "props", localConsts)
end

function refreshConstsTab()
    -- remove everything in the const rows
    for i, row in ipairs(constRows) do
        destroyElement(row.key)
        destroyElement(row.input)
        destroyElement(row.nilToggle)

    end

    local consts = getConst().consts
    --loop over const keys and values and create inpuyts for each and store in const rows
    local index = 1
    for key, value in pairs(consts) do
        local yPos = 0.01 + (index * 0.03)
        local keyLabel = guiCreateLabel(0.01, yPos, 0.14, 0.02, key, true, constTab)
        guiLabelSetHorizontalAlign(keyLabel, "right", false)
        guiLabelSetVerticalAlign(keyLabel, "center")
        local input = guiCreateEdit(0.15, yPos, 0.06, 0.02, value, true, constTab)
        local nilToggle = guiCreateCheckBox(0.22, yPos, 0.07, 0.02, "Nil", value == nil, true, constTab)
        addEventHandler("onClientGUIChanged", input, function(element) 
            local text = guiGetText(element)
            local asNumber = tonumber(text)
            localConsts.consts[key] = asNumber
         end)

        table.insert(constRows, {key = keyLabel, input = input, nilToggle = nilToggle})
        index = index + 1
    end
end

function createWindow()
    adminWindow = guiCreateWindow(0.01, 0.01, 0.99, 0.96, "", true)
    guiWindowSetSizable(adminWindow, false)

    tabs = guiCreateTabPanel(0.00, 0.02, 0.97, 0.97, true, adminWindow)

    constTab = guiCreateTab("Constants", tabs)

    refreshConstsTab()

    powerTab = guiCreateTab("Powers", tabs)

    powersScrollpane = guiCreateScrollPane(0.00, 0.01, 0.99, 0.98, true, powerTab)

    powerKeyLabel = guiCreateLabel(0.00, 0.01, 0.08, 0.02, "power.key", true, powersScrollpane)
    guiLabelSetHorizontalAlign(powerKeyLabel, "right", false)
    guiLabelSetVerticalAlign(powerKeyLabel, "center")
    durationLabel = guiCreateLabel(0.09, 0.01, 0.03, 0.02, "Duration", true, powersScrollpane)
    guiLabelSetHorizontalAlign(durationLabel, "right", false)
    guiLabelSetVerticalAlign(durationLabel, "center")
    durationInput = guiCreateEdit(0.12, 0.01, 0.02, 0.02, "", true, powersScrollpane)
    cooldownLabel = guiCreateLabel(0.15, 0.01, 0.03, 0.02, "Cooldown", true, powersScrollpane)
    guiLabelSetHorizontalAlign(cooldownLabel, "right", false)
    guiLabelSetVerticalAlign(cooldownLabel, "center")
    cooldownInput = guiCreateEdit(0.18, 0.01, 0.02, 0.02, "", true, powersScrollpane)


    playerTab = guiCreateTab("Players", tabs)

    GUIEditor.label[1] = guiCreateLabel(0.01, 0.02, 0.10, 0.02, "playerName", true, playerTab)
    guiLabelSetHorizontalAlign(GUIEditor.label[1], "right", false)
    guiLabelSetVerticalAlign(GUIEditor.label[1], "center")
    scoreLabel = guiCreateLabel(0.11, 0.02, 0.02, 0.02, "Score", true, playerTab)
    guiLabelSetHorizontalAlign(scoreLabel, "right", false)
    guiLabelSetVerticalAlign(scoreLabel, "center")
    scoreInput = guiCreateEdit(0.14, 0.02, 0.04, 0.02, "", true, playerTab)
    moneyLabel = guiCreateLabel(0.18, 0.02, 0.02, 0.02, "Money", true, playerTab)
    guiLabelSetHorizontalAlign(moneyLabel, "right", false)
    guiLabelSetVerticalAlign(moneyLabel, "center")
    moneyInput = guiCreateEdit(0.21, 0.02, 0.04, 0.02, "", true, playerTab)
    GUIEditor.label[2] = guiCreateLabel(0.25, 0.02, 0.02, 0.02, "Rank", true, playerTab)
    guiLabelSetHorizontalAlign(GUIEditor.label[2], "right", false)
    guiLabelSetVerticalAlign(GUIEditor.label[2], "center")
    GUIEditor.edit[1] = guiCreateEdit(0.27, 0.02, 0.02, 0.02, "", true, playerTab)
    killButton = guiCreateButton(0.30, 0.02, 0.03, 0.02, "Kill", true, playerTab)
    giveGoldButton = guiCreateButton(0.33, 0.02, 0.03, 0.02, "Give gold", true, playerTab)

    controlTab = guiCreateTab("Control", tabs)

    respawnGoldAtEdlButton = guiCreateButton(0.02, 0.02, 0.07, 0.03, "Respawn gold at edl", true, controlTab)
    newRoundButton = guiCreateButton(0.09, 0.02, 0.07, 0.03, "New round", true, controlTab)
    respawnAtNewLocationButton = guiCreateButton(0.02, 0.05, 0.07, 0.04, "Respawn gold at new location", true, controlTab)
    newRoundButton = guiCreateButton(0.16, 0.02, 0.07, 0.03, "New round", true, controlTab)

    saveButton = guiCreateButton(0.87, 0.02, 0.06, 0.05, "Save", true, adminWindow)
    closeButton = guiCreateButton(0.93, 0.02, 0.06, 0.05, "Close", true, adminWindow)
    
    addEventHandler("onClientGUIClick", saveButton, function()
        guiSetInputEnabled(false)
        showCursor(false)
        guiSetVisible(adminWindow, false)
        saveConsts()
    end, false)
    addEventHandler("onClientGUIClick", saveButton, function()
        guiSetInputEnabled(false)
        showCursor(false)
        guiSetVisible(adminWindow, false)
        saveConsts()
    end, false)
end

function bindConfigPowerKeys(player)
    -- outputChatBox("bindConfigPowerKeys")
      bindKey ( "F6", "up", toggleWindow )
  end
  
  function unbindConfigPowerKeys(player)
      unbindKey ( "F6" )
  end
  
  function onJoinForPowerKeys ( )
      bindConfigPowerKeys(source)
  end
  addEventHandler("onPlayerJoin", getRootElement(), onJoinForPowerKeys)
  
    --unbind on quit
  function onQuitForPowerKeys ( )
      unbindConfigPowerKeys(source)
  end
  addEventHandler("onPlayerQuit", getRootElement(), onQuitForPowerKeys)
  
  addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
    -- outputChatBox("onClientResourceStart3333"..inspect(source))
      bindConfigPowerKeys(source)
  end)