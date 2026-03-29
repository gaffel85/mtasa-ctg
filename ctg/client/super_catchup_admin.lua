local DGS = exports.dgs
local adminWindow = nil
local playerList = nil

local function updatePlayerList()
    if not playerList then return end
    DGS:dgsGridListClear(playerList)
    for _, player in ipairs(getElementsByType("player")) do
        local row = DGS:dgsGridListAddRow(playerList)
        DGS:dgsGridListSetItemText(playerList, row, 1, getPlayerName(player))
        local hasPower = getElementData(player, "hasSuperCatchup")
        DGS:dgsGridListSetItemText(playerList, row, 2, hasPower and "Yes" or "No")
        DGS:dgsGridListSetItemColor(playerList, row, 2, hasPower and tocolor(0, 255, 0) or tocolor(255, 0, 0))
    end
end

local function toggleAdminWindow()
    if getPlayerName(localPlayer) ~= "gaffel" then return end

    if adminWindow then
        DGS:dgsCloseWindow(adminWindow)
        adminWindow = nil
        showCursor(false)
    else
        local screenW, screenH = guiGetScreenSize()
        local width, height = 400, 500
        adminWindow = DGS:dgsCreateWindow((screenW - width) / 2, (screenH - height) / 2, width, height, "Super Catch-Up Admin", false)
        DGS:dgsWindowSetCloseButtonEnabled(adminWindow, false)
        
        playerList = DGS:dgsCreateGridList(10, 10, width - 20, height - 100, false, adminWindow)
        DGS:dgsGridListAddColumn(playerList, "Player", 0.6)
        DGS:dgsGridListAddColumn(playerList, "Power", 0.3)
        
        updatePlayerList()
        
        local grantBtn = DGS:dgsCreateButton(10, height - 80, (width - 30) / 2, 30, "Toggle Power", false, adminWindow)
        local closeBtn = DGS:dgsCreateButton(width / 2 + 5, height - 80, (width - 30) / 2, 30, "Close", false, adminWindow)
        
        addEventHandler("onDgsMouseClickUp", grantBtn, function()
            local selectedRow = DGS:dgsGridListGetSelectedItem(playerList)
            if selectedRow ~= -1 then
                local playerName = DGS:dgsGridListGetItemText(playerList, selectedRow, 1)
                local targetPlayer = getPlayerFromName(playerName)
                if targetPlayer then
                    local currentStatus = getElementData(targetPlayer, "hasSuperCatchup")
                    triggerServerEvent("onSuperCatchupToggle", resourceRoot, targetPlayer, not currentStatus)
                    setTimer(updatePlayerList, 200, 1) -- Small delay to allow sync
                end
            end
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
