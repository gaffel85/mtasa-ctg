local DGS = exports.dgs
local adminWindow = nil
local playerList = nil
local destCombo = nil
local momentumRows = {}
local localConsts = nil

local function updatePlayerList()
    if not playerList then return end
    DGS:dgsGridListClear(playerList)
    if destCombo then DGS:dgsComboBoxClear(destCombo) end
    
    for _, player in ipairs(getElementsByType("player")) do
        local playerName = getPlayerName(player)
        
        -- Update Grid List
        local row = DGS:dgsGridListAddRow(playerList)
        DGS:dgsGridListSetItemText(playerList, row, 1, playerName)
        local hasPower = getElementData(player, "hasSuperCatchup")
        DGS:dgsGridListSetItemText(playerList, row, 2, hasPower and "Yes" or "No")
        DGS:dgsGridListSetItemColor(playerList, row, 2, hasPower and tocolor(0, 255, 0) or tocolor(255, 0, 0))
        
        -- Update Destination Combo
        if destCombo then
            DGS:dgsComboBoxAddItem(destCombo, playerName)
        end
    end
end

local function refreshMomentumTab(tab)
    -- Clear previous rows
    for _, row in ipairs(momentumRows) do
        if isElement(row.label) then destroyElement(row.label) end
        if isElement(row.edit) then destroyElement(row.edit) end
    end
    momentumRows = {}

    localConsts = getElementData(resourceRoot, "props")
    if not localConsts or not localConsts.momentum then return end

    local index = 0
    for key, value in pairs(localConsts.momentum) do
        local yPos = 10 + (index * 35)
        local label = DGS:dgsCreateLabel(10, yPos, 150, 30, key, false, tab)
        DGS:dgsSetProperty(label, "alignment", {"right", "center"})
        
        local edit = DGS:dgsCreateEdit(170, yPos, 100, 30, tostring(value), false, tab)
        
        table.insert(momentumRows, {label = label, edit = edit, key = key})
        index = index + 1
    end
end

local function toggleAdminWindow()
    -- Maintain existing permission check
    -- if getPlayerName(localPlayer) ~= "gaffel" then return end

    if adminWindow then
        DGS:dgsCloseWindow(adminWindow)
        adminWindow = nil
        showCursor(false)
    else
        local screenW, screenH = guiGetScreenSize()
        local width, height = 500, 700
        adminWindow = DGS:dgsCreateWindow((screenW - width) / 2, (screenH - height) / 2, width, height, "Admin Panel", false)
        DGS:dgsWindowSetCloseButtonEnabled(adminWindow, false)
        
        local tabPanel = DGS:dgsCreateTabPanel(0, 0, width, height - 80, false, adminWindow)
        
        -- Players Tab (Original Super Catch-up logic)
        local playerTab = DGS:dgsCreateTab("Players", tabPanel)
        playerList = DGS:dgsCreateGridList(10, 10, width - 20, height - 300, false, playerTab)
        DGS:dgsGridListAddColumn(playerList, "Player", 0.6)
        DGS:dgsGridListAddColumn(playerList, "Power", 0.3)
        
        local grantBtn = DGS:dgsCreateButton(10, height - 280, (width - 30) / 2, 30, "Toggle Super Catchup", false, playerTab)
        addEventHandler("onDgsMouseClickUp", grantBtn, function()
            local selectedRow = DGS:dgsGridListGetSelectedItem(playerList)
            if selectedRow ~= -1 then
                local playerName = DGS:dgsGridListGetItemText(playerList, selectedRow, 1)
                local targetPlayer = getPlayerFromName(playerName)
                if targetPlayer then
                    local currentStatus = getElementData(targetPlayer, "hasSuperCatchup")
                    triggerServerEvent("onSuperCatchupToggle", resourceRoot, targetPlayer, not currentStatus)
                    setTimer(updatePlayerList, 200, 1)
                end
            end
        end, false)

        local scoreEdit = DGS:dgsCreateEdit(width / 2 + 5, height - 280, 60, 30, "0", false, playerTab)
        local setScoreBtn = DGS:dgsCreateButton(width / 2 + 70, height - 280, width / 2 - 80, 30, "Set Score", false, playerTab)
        addEventHandler("onDgsMouseClickUp", setScoreBtn, function()
            local selectedRow = DGS:dgsGridListGetSelectedItem(playerList)
            if selectedRow ~= -1 then
                local playerName = DGS:dgsGridListGetItemText(playerList, selectedRow, 1)
                local score = tonumber(DGS:dgsGetText(scoreEdit))
                if score then
                    triggerServerEvent("fromClientSetPlayerScore", resourceRoot, playerName, score)
                end
            end
        end, false)

        local fixBtn = DGS:dgsCreateButton(10, height - 240, width - 20, 30, "Fix & Respawn Player", false, playerTab)
        addEventHandler("onDgsMouseClickUp", fixBtn, function()
            local selectedRow = DGS:dgsGridListGetSelectedItem(playerList)
            if selectedRow ~= -1 then
                local playerName = DGS:dgsGridListGetItemText(playerList, selectedRow, 1)
                triggerServerEvent("adminFixPlayer", resourceRoot, playerName)
            end
        end, false)

        -- Teleport UI
        DGS:dgsCreateLabel(10, height - 200, 100, 30, "Teleport to:", false, playerTab)
        destCombo = DGS:dgsCreateComboBox(110, height - 205, width - 120, 30, "Select Player", false, playerTab)
        
        local teleportBtn = DGS:dgsCreateButton(10, height - 165, width - 20, 30, "Teleport Selected to Destination", false, playerTab)
        addEventHandler("onDgsMouseClickUp", teleportBtn, function()
            local selectedRow = DGS:dgsGridListGetSelectedItem(playerList)
            local destItem = DGS:dgsComboBoxGetSelectedItem(destCombo)
            
            if selectedRow ~= -1 and destItem ~= -1 then
                local targetName = DGS:dgsGridListGetItemText(playerList, selectedRow, 1)
                local destName = DGS:dgsComboBoxGetItemText(destCombo, destItem)
                
                triggerServerEvent("adminTeleportPlayerToPlayer", resourceRoot, targetName, destName)
            else
                outputChatBox("Select both a target player and a destination player.", 255, 0, 0)
            end
        end, false)

        updatePlayerList()

        -- Gold Tab
        local goldTab = DGS:dgsCreateTab("Gold", tabPanel)
        local spawnGold10sBtn = DGS:dgsCreateButton(10, 10, width - 20, 30, "Spawn Gold @ Carrier 10s Ago", false, goldTab)
        local respawnClosestBtn = DGS:dgsCreateButton(10, 50, width - 20, 30, "Respawn Gold (Closest Spawn)", false, goldTab)
        local respawnLastBtn = DGS:dgsCreateButton(10, 90, width - 20, 30, "Respawn Gold (Last Spawn)", false, goldTab)
        local respawnRandomBtn = DGS:dgsCreateButton(10, 130, width - 20, 30, "Respawn Gold (Random Nearby 100m)", false, goldTab)

        addEventHandler("onDgsMouseClickUp", spawnGold10sBtn, function()
            triggerServerEvent("adminSpawnGoldAt10sAgo", resourceRoot)
        end, false)

        addEventHandler("onDgsMouseClickUp", respawnClosestBtn, function()
            triggerServerEvent("adminRespawnGoldClosest", resourceRoot)
        end, false)

        addEventHandler("onDgsMouseClickUp", respawnLastBtn, function()
            triggerServerEvent("adminRespawnGoldLast", resourceRoot)
        end, false)

        addEventHandler("onDgsMouseClickUp", respawnRandomBtn, function()
            triggerServerEvent("adminRespawnGoldRandomNearby", resourceRoot)
        end, false)

        -- Momentum Tab
        local momentumTab = DGS:dgsCreateTab("Momentum", tabPanel)
        local scrollPane = DGS:dgsCreateScrollPane(0, 0, width, height - 120, false, momentumTab)
        refreshMomentumTab(scrollPane)

        -- Game State Tab
        local gameStateTab = DGS:dgsCreateTab("Game State", tabPanel)
        local saveStateBtn = DGS:dgsCreateButton(10, 10, width - 20, 30, "Save Score & Teams", false, gameStateTab)
        local loadStateBtn = DGS:dgsCreateButton(10, 50, width - 20, 30, "Load Score & Teams", false, gameStateTab)

        addEventHandler("onDgsMouseClickUp", saveStateBtn, function()
            triggerServerEvent("saveGameState", resourceRoot)
        end, false)

        addEventHandler("onDgsMouseClickUp", loadStateBtn, function()
            triggerServerEvent("loadGameState", resourceRoot)
        end, false)
        
        -- Footer Controls
        local saveBtn = DGS:dgsCreateButton(10, height - 40, (width - 30) / 2, 30, "Save Props", false, adminWindow)
        local closeBtn = DGS:dgsCreateButton(width / 2 + 5, height - 40, (width - 30) / 2, 30, "Close", false, adminWindow)
        
        addEventHandler("onDgsMouseClickUp", saveBtn, function()
            -- Force update all values from edit boxes to our local table
            if localConsts and localConsts.momentum then
                for _, row in ipairs(momentumRows) do
                    local valStr = DGS:dgsGetText(row.edit)
                    local valNum = tonumber(valStr)
                    if valNum then
                        localConsts.momentum[row.key] = valNum
                    end
                end
            end

            -- Sync local changes to the server to persist them
            triggerServerEvent("savePropsFromServer", resourceRoot, localConsts)
            outputChatBox("Properties saved and synced to server.", 0, 255, 0)
        end, false)
        
        addEventHandler("onDgsMouseClickUp", closeBtn, function()
            DGS:dgsCloseWindow(adminWindow)
            adminWindow = nil
            showCursor(false)
        end, false)
        
        showCursor(true)
    end
end

bindKey("F6", "down", toggleAdminWindow)
