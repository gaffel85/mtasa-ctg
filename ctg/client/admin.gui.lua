local adminWindow = nil
local constTab = nil
local powerTab = nil
local playerTab = nil
local controlTab = nil
local saveButton = nil
local closeButton = nil

local constRows = {}
local powerRows = {}
local playerRows = {}

local localConsts = nil

GUIEditor = {
    tab = {},
    window = {},
    edit = {},
    label = {}
}

function setPlayerMoneyOnServer(player, money)
    triggerServerEvent("fromClientSetPlayerMoney", getPlayerName(player), money)
end

function setPlayerScoreOnServer(player, score)
    triggerServerEvent("fromClientSetPlayerScore", getPlayerName(player), score)
end

function setPlayerRankOnServer(player, rank)
    triggerServerEvent("fromClientSetPlayerRank", getPlayerName(player), rank)
end

function closeWindow() 
    guiSetInputEnabled(false)
    showCursor(false)
    guiSetVisible(adminWindow, false)
end

function toggleAdminWindow()
    if (adminWindow == nil) then
        createWindow()
    end
    if guiGetVisible(adminWindow) then
        closeWindow()
    else
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

function getScore()
    return getElementData(player, "Score")
end

function saveConsts()
    outputConsole("saveConsts")
    --outputConsole("saveConsts "..inspect(localConsts))
    setElementData(resourceRoot, "props", localConsts)

    --save to file based on timestamp
    local timestamp = getRealTime().timestamp
    local filename = "ctg_"..timestamp..".txt"
    local file = fileCreate(filename)
    if not file then
        outputConsole("Failed to create file "..filename)
        return
    end
    fileWrite(file, inspect(localConsts))
    fileClose(file)
end

function refreshAll()
    refreshConstsTab()
    refreshPowersTab()
    -- refreshPlayers()
end

function refreshPlayers()
    local yPos = 0.02
    --loop over all players and create a row for each player
    for i, player in ipairs(getElementsByType("player")) do
        local playerName = getPlayerName(player)
        local score = getElementData(player, "score")
        local money = getPlayerMoney(player)
        local rank = getCompletedRank(player)

        -- create ui elements for each player
        local playerName = guiCreateLabel(0.01, yPos, 0.10, 0.02, playerName, true, playerTab)
        guiLabelSetHorizontalAlign(playerName, "right", false)
        guiLabelSetVerticalAlign(playerName, "center")
        local scoreLabel = guiCreateLabel(0.11, yPos, 0.02, 0.02, "Score", true, playerTab)
        guiLabelSetHorizontalAlign(scoreLabel, "right", false)
        guiLabelSetVerticalAlign(scoreLabel, "center")
        local scoreInput = guiCreateEdit(0.14, yPos, 0.04, 0.02, score, true, playerTab)
        addEventHandler("onClientGUIBlur", scoreInput, function() 
            local text = guiGetText(source)
            local asNumber = tonumber(text)
            setElementData(player, "Score", asNumber)
         end)
        local moneyLabel = guiCreateLabel(0.18, yPos, 0.02, 0.02, "Money", true, playerTab)
        guiLabelSetHorizontalAlign(moneyLabel, "right", false)
        guiLabelSetVerticalAlign(moneyLabel, "center")
        local moneyInput = guiCreateEdit(0.21, yPos, 0.04, 0.02, money, true, playerTab)
        addEventHandler("onClientGUIBlur", moneyInput, function() 
            local text = guiGetText(source)
            local asNumber = tonumber(text)
            setPlayerMoney(asNumber)
         end)
        local rankLabel = guiCreateLabel(0.25, yPos, 0.02, 0.02, "Rank", true, playerTab)
        guiLabelSetHorizontalAlign(rankLabel, "right", false)
        guiLabelSetVerticalAlign(rankLabel, "center")
        local rankInput = guiCreateEdit(0.27, yPos, 0.02, 0.02, rank, true, playerTab)
        addEventHandler("onClientGUIBlur", rankInput, function() 
            local text = guiGetText(source)
            local asNumber = tonumber(text)
            outputChatBox("setting rank "..inspect(asNumber))
            setRank(player, asNumber)
         end)
        killButton = guiCreateButton(0.30, yPos, 0.03, 0.02, "Kill", true, playerTab)
        giveGoldButton = guiCreateButton(0.33, yPos, 0.03, 0.02, "Give gold", true, playerTab)

        local row = {scoreInput = scoreInput, moneyInput = moneyInput, rankInput = rankInput, killButton = killButton, giveGoldButton = giveGoldButton, playerNameLabel = playerName, scoreLabel = scoreLabel, moneyLabel = moneyLabel, rankLabel = rankLabel}
        table.insert(playerRows, row)
        yPos = yPos + 0.03
    end
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
    -- remove everything in the power rows
    for i, row in ipairs(powerRows) do
        if isElement(row.key) then
            destroyElement(row.key)
        end
        for j, input in ipairs(row.inputs) do
            if isElement(input.label) then
                destroyElement(input.label)
            end
            if isElement(input.input) then
                destroyElement(input.input)
            end
        end
    end

    local powers = getProps().powers
    local index = 1
    outputConsole("powers "..inspect(powers))
    for key, value in pairs(powers) do
        local yPos = 0.01 + (index * 0.05)
        local keyLabel = guiCreateLabel(0.01, yPos, 0.07, 0.02, key, true, powerTab)
        guiLabelSetHorizontalAlign(keyLabel, "right", false)
        guiLabelSetVerticalAlign(keyLabel, "center")

        local fixedPoperties = { "duration", "cooldown", "initCooldown", "allowedGoldCarrier", "charges", "rank" }
        -- each power has some fixed properties but can also has more properties. Create loop over each attribute. Start with the fixed ones and add custom ones in the end. Each attribute should have the label, and input
        local xPos = 0.09
        local inputs = {}
        for i, prop in ipairs(fixedPoperties) do
            local label = guiCreateLabel(xPos, yPos, 0.05, 0.02, prop, true, powerTab)
            guiLabelSetHorizontalAlign(label, "right", false)
            guiLabelSetVerticalAlign(label, "center")
            local input = nil
            if prop == "allowedGoldCarrier" then
                input = guiCreateCheckBox(xPos + 0.06, yPos, 0.015, 0.02, "", value[prop], true, powerTab)
                addEventHandler("onClientGUIClick", input, function()
                    --localConsts.powers[key][prop] = guiCheckBoxGetSelected(source)
                end)
            else
                local propVal = value[prop]
                if propVal == nil then
                    propVal = 0
                end
                input = guiCreateEdit(xPos + 0.06, yPos, 0.015, 0.02, propVal, true, powerTab)
                addEventHandler("onClientGUIChanged", input, function() 
                    local text = guiGetText(source)
                    local asNumber = tonumber(text)
                    if (asNumber == 0) then
                         localConsts.powers[key][prop] = nil
                    else
                        localConsts.powers[key][prop] = asNumber
                    end
                end)
            end
            table.insert(inputs, {label = label, input = input})
            xPos = xPos + 0.1
        end

        -- loop for custom properties that's not the fixed ones
        --for customKey, customValue in pairs(value) do
        --    if not contains(fixedPoperties, customKey) then
        --        local label = guiCreateLabel(xPos, yPos, 0.03, 0.02, "2:"..customKey, true, powerTab)
        --        guiLabelSetHorizontalAlign(label, "right", false)
        --        guiLabelSetVerticalAlign(label, "center")
        --        local input = guiCreateEdit(xPos + 7, yPos, 0.06, 0.02, customValue, true, powerTab)
        --        addEventHandler("onClientGUIChanged", input, function() 
         --           local text = guiGetText(source)
        --            local asNumber = tonumber(text)
        --            if (asNumber == 0) then
        ----                localConsts.powers[key][customKey] = nil
        --            else
        --                localConsts.powers[key][customKey] = asNumber
        --            end
        --        end)
        --        table.insert(inputs, {label = label, input = input})
        --        xPos = xPos + 0.07
        --    end
        --end

        table.insert(powerRows, {key = keyLabel, inputs = inputs})
        index = index + 1
    end
end

function getIndex(tab, val)
    local index = nil
    for i, v in ipairs (tab) do 
        if (v == val) then
          index = i 
        end
    end
    return index
end

function contains(tab, val)
    local idx = getIndex(tab, val)
    if idx then 
        return true
    end
    return false
end

function createWindow()
    adminWindow = guiCreateWindow(0.01, 0.01, 0.99, 0.96, "", true)
    guiWindowSetSizable(adminWindow, false)

    tabs = guiCreateTabPanel(0.00, 0.02, 0.97, 0.97, true, adminWindow)

    constTab = guiCreateTab("Constants", tabs)
    
    powerTab = guiCreateTab("Powers", tabs)
    --powersScrollpane = guiCreateScrollPane(0.00, 0.01, 0.99, 0.98, true, powerTab)

    playerTab = guiCreateTab("Players", tabs)

    controlTab = guiCreateTab("Control", tabs)

    respawnGoldAtEdlButton = guiCreateButton(0.02, 0.02, 0.07, 0.03, "Respawn gold at edl", true, controlTab)
    newRoundButton = guiCreateButton(0.09, 0.02, 0.07, 0.03, "New round", true, controlTab)
    respawnAtNewLocationButton = guiCreateButton(0.02, 0.05, 0.07, 0.04, "Respawn gold at new location", true, controlTab)
    local plotButton = guiCreateButton(0.16, 0.02, 0.07, 0.03, "Plot", true, controlTab)
    addEventHandler("onClientGUIClick", newRoundButton, function() 
        triggerServerEvent("forceNextRoundFromClient", resourceRoot)
    end, false)
    addEventHandler("onClientGUIClick", plotButton, function() 
        triggerServerEvent("plotPointsFromClient", resourceRoot)
    end, false)

    saveButton = guiCreateButton(0.87, 0.92, 0.06, 0.02, "Save", true, constTab)
    closeButton = guiCreateButton(0.93, 0.92, 0.06, 0.02, "Close", true, constTab)
    addEventHandler("onClientGUIClick", saveButton, function() saveConsts() end, false)
    addEventHandler("onClientGUIClick", closeButton, function() closeWindow() end, false)

    local saveButton2 = guiCreateButton(0.87, 0.92, 0.06, 0.02, "Save", true, powerTab)
    local closeButton2 = guiCreateButton(0.93, 0.92, 0.06, 0.02, "Close", true, powerTab)
    addEventHandler("onClientGUIClick", saveButton2, function() saveConsts() end, false)
    addEventHandler("onClientGUIClick", closeButton2, function() closeWindow() end, false)

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