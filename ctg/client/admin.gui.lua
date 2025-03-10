local adminWindow = nil
local constTab = nil
local powerTab = nil
local playerTab = nil
local controlTab = nil
local saveButton = nil
local closeButton = nil

local constRows = {}
local powerRows = {}

local localConsts = nil

GUIEditor = {
    tab = {},
    window = {},
    edit = {},
    label = {}
}

function toggleAdminWindow()
    if (adminWindow == nil) then
        outputConsole("creating admin window")
        createWindow()
    end
    if guiGetVisible(adminWindow) then
        outputConsole("adminWindow is open, closing it")
        guiSetVisible(adminWindow, false)
        guiSetInputEnabled(false)
        showCursor(false)
    else
        outputConsole("adminWindow is closed, opening it")
        guiSetVisible(adminWindow, true)
        guiSetInputEnabled(true)
        showCursor(true)
        refreshAll()
    end
end

function getProps()
    localConsts = getElementData(resourceRoot, "props")
    return localConsts
end

function saveConsts()
    outputConsole("saveConsts "..inspect(localConsts))
    setElementData(resourceRoot, "props", localConsts)

    --save to file based on timestamp
    local timestamp = getRealTime().timestamp
    local file = fileCreate("ctg_"..timestamp..".txt")
    if not file then
        outputConsole("Failed to create file")
        return
    end
    fileWrite(file, inspect(localConsts))
    fileClose(file)
end

function refreshAll()
    refreshConstsTab()
    refreshPowersTab()
end

function refreshConstsTab()
    -- remove everything in the const rows
    for i, row in ipairs(constRows) do
        if isElement(row.key) then
            destroyElement(row.key)
        end
        if isElement(row.input) then
            destroyElement(row.input)
        end
        if isElement(row.nilToggle) then
            destroyElement(row.nilToggle)
        end
    end
    constRows = {}

    local consts = getProps().consts
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

function refreshPowersTab()
    local powers = getProps().powers
    local index = 1
    for key, value in pairs(powers) do
        local yPos = 0.01 + (index * 0.03)
        local keyLabel = guiCreateLabel(0.01, yPos, 0.14, 0.02, key, true, powersScrollpane)
        guiLabelSetHorizontalAlign(keyLabel, "right", false)
        guiLabelSetVerticalAlign(keyLabel, "center")

        durationLabel = guiCreateLabel(0.09, yPos, 0.03, 0.02, "Duration", true, powersScrollpane)
        guiLabelSetHorizontalAlign(durationLabel, "right", false)
        guiLabelSetVerticalAlign(durationLabel, "center")
        local durationInput = guiCreateEdit(0.15, yPos, 0.06, 0.02, value.duration, true, powersScrollpane)
        addEventHandler("onClientGUIChanged", durationInput, function(element) 
            local text = guiGetText(element)
            local asNumber = tonumber(text)
            localConsts.powers[key].duration = asNumber
         end)

        cooldownLabel = guiCreateLabel(0.15, yPos, 0.03, 0.02, "Cooldown", true, powersScrollpane)
        guiLabelSetHorizontalAlign(cooldownLabel, "right", false)
        guiLabelSetVerticalAlign(cooldownLabel, "center")
        local cooldownInput = guiCreateEdit(0.22, yPos, 0.06, 0.02, value.cooldown, true, powersScrollpane)
        addEventHandler("onClientGUIChanged", cooldownInput, function(element) 
            local text = guiGetText(element)
            local asNumber = tonumber(text)
            localConsts.powers[key].cooldown = asNumber
         end)

        table.insert(powerRows, {key = keyLabel, duration = durationInput, cooldown = cooldownInput})
        index = index + 1
    end
end

function createWindow()
    adminWindow = guiCreateWindow(0.01, 0.01, 0.99, 0.96, "", true)
    guiWindowSetSizable(adminWindow, false)

    tabs = guiCreateTabPanel(0.00, 0.02, 0.97, 0.97, true, adminWindow)

    constTab = guiCreateTab("Constants", tabs)
    
    powerTab = guiCreateTab("Powers", tabs)
    powersScrollpane = guiCreateScrollPane(0.00, 0.01, 0.99, 0.98, true, powerTab)

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

    saveButton = guiCreateButton(0.87, 0.92, 0.06, 0.02, "Save", true, constTab)
    closeButton = guiCreateButton(0.93, 0.92, 0.06, 0.02, "Close", true, constTab)
    
    addEventHandler("onClientGUIClick", saveButton, function()
        saveConsts()
    end, false)
    addEventHandler("onClientGUIClick", closeButton, function()
        guiSetInputEnabled(false)
        showCursor(false)
        guiSetVisible(adminWindow, false)
    end, false)

    guiSetVisible(adminWindow, false)
end

function bindConfigAdminKeys(player)
    -- outputChatBox("bindConfigAdminKeys")
      bindKey ( "F6", "up", toggleAdminWindow )
  end
  
  function unbindConfigAdminKeys(player)
      unbindKey ( "F6" )
  end
  
  function onJoinForAdminKeys ( )
      bindConfigAdminKeys(source)
  end
  addEventHandler("onPlayerJoin", getRootElement(), onJoinForAdminKeys)
  
    --unbind on quit
  function onQuitForAdminKeys ( )
      unbindConfigAdminKeys(source)
  end
  addEventHandler("onPlayerQuit", getRootElement(), onQuitForAdminKeys)
  
  addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
    -- outputChatBox("onClientResourceStart3333"..inspect(source))
      bindConfigAdminKeys(source)
  end)