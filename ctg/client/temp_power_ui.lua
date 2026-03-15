-- ctg/client/temp_power_ui.lua
-- Client-side module for displaying the player's temporary power-up queue using DGS.

local DGS = exports.dgs

local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()
local UI_BASE_X = SCREEN_WIDTH / 2 -- Center horizontally
local UI_BASE_Y = SCREEN_HEIGHT - 140 -- Positioned lower
local CARD_WIDTH = 400
local CARD_HEIGHT = 120
local CARD_SPACING = 20

local playerPowerupQueue = {} -- The client's current temporary power-up queue
local activeEffects = {} -- Stores active temporary power-up effects for progress bars
local warningEffect = nil -- { playerName, name, endTime, duration }
local textureCache = {} -- Cache for power-up icons
local lastQueueIds = {nil, nil} -- Keep track of last displayed IDs to avoid redundant updates
local lastLockState = false

-- DGS Elements
local cardElements = {} -- { [1] = elements, [2] = elements }
local activeEffectUI = nil -- Single UI element set for the active power
local warningUI = nil -- { container, icon, label }

local function getIconTexture(path)
    if not path then return nil end
    if textureCache[path] then return textureCache[path] end
    
    if fileExists(path) then
        local texture = dxCreateTexture(path, "argb", true, "clamp")
        if texture then
            textureCache[path] = texture
            return texture
        end
    end
    return nil
end

local function createPowerupCard(index)
    local card = {}
    local x = (index == 1) and (UI_BASE_X - CARD_WIDTH / 2) or (UI_BASE_X - CARD_WIDTH / 2 + 10)
    local y = (index == 1) and UI_BASE_Y or (UI_BASE_Y - 40)
    
    card.bg = DGS:dgsCreateImage(x, y, CARD_WIDTH, CARD_HEIGHT, nil, false)
    DGS:dgsSetProperty(card.bg, "color", tocolor(0, 0, 0, 255))
    
    -- Rounded corners if possible
    local rndRect = DGS:dgsCreateRoundRect(10, false, tocolor(0, 0, 0, 255), nil, nil, nil, true)
    DGS:dgsSetProperty(card.bg, "image", rndRect)

    -- Border
    card.border = DGS:dgsCreateImage(0, 0, 1, 1, nil, true, card.bg)
    local borderRect = DGS:dgsCreateRoundRect(10, false, tocolor(0, 0, 0, 0), tocolor(255, 255, 255, 255), 2, true)
    DGS:dgsSetProperty(card.border, "image", borderRect)
    DGS:dgsSetEnabled(card.border, false)

    -- Icon
    card.icon = DGS:dgsCreateImage(CARD_WIDTH - CARD_HEIGHT + 10, 10, CARD_HEIGHT - 20, CARD_HEIGHT - 20, nil, false, card.bg)
    
    -- Name
    card.name = DGS:dgsCreateLabel(15, 10, CARD_WIDTH - CARD_HEIGHT - 10, 30, "", false, card.bg)
    DGS:dgsSetProperty(card.name, "textSize", {1.5, 1.5})
    DGS:dgsSetProperty(card.name, "font", "default-bold")
    
    -- Description
    card.description = DGS:dgsCreateLabel(15, 45, CARD_WIDTH - CARD_HEIGHT - 10, CARD_HEIGHT - 55, "", false, card.bg)
    DGS:dgsSetProperty(card.description, "wordBreak", true)
    DGS:dgsSetProperty(card.description, "color", tocolor(200, 200, 200, 255))

    -- NEXT label
    card.nextLabel = DGS:dgsCreateLabel(0, -30, CARD_WIDTH, 25, "NEXT", false, card.bg)
    DGS:dgsSetProperty(card.nextLabel, "alignment", {"center", "center"})
    DGS:dgsSetProperty(card.nextLabel, "font", "default-bold")
    DGS:dgsSetVisible(card.nextLabel, false)

    -- LOCKED label
    card.lockedLabel = DGS:dgsCreateLabel(0, 0, CARD_WIDTH, CARD_HEIGHT, "Other power active", false, card.bg)
    DGS:dgsSetProperty(card.lockedLabel, "alignment", {"center", "center"})
    DGS:dgsSetProperty(card.lockedLabel, "font", "default-bold")
    DGS:dgsSetProperty(card.lockedLabel, "textSize", {1.5, 1.5})
    DGS:dgsSetProperty(card.lockedLabel, "color", tocolor(255, 100, 100, 255))
    DGS:dgsSetVisible(card.lockedLabel, false)

    DGS:dgsSetVisible(card.bg, false)
    return card
end

local function initUI()
    if #cardElements > 0 then return end
    
    cardElements[1] = createPowerupCard(1)
    cardElements[2] = createPowerupCard(2)
    
    -- Layering: Card 1 should be on top of Card 2
    DGS:dgsSetLayer(cardElements[1].bg, "top")
    
    -- Active Effects UI (Single container/elements)
    local width = 250
    local powerLabelHeight = 70
    local progressHeight = 25
    local playerLabelHeight = 20
    local spacing = 4
    local totalHeight = powerLabelHeight + progressHeight + playerLabelHeight + (spacing * 2)
    
    local containerY = (SCREEN_HEIGHT / 2 - 100) - (SCREEN_HEIGHT * 0.15)
    local container = DGS:dgsCreateImage(20, containerY, width, totalHeight, nil, false)
    DGS:dgsSetProperty(container, "color", tocolor(0, 0, 0, 0))
    DGS:dgsSetVisible(container, false)

    local powerLabel = DGS:dgsCreateLabel(0, 0, width, powerLabelHeight, "", false, container)
    DGS:dgsSetProperty(powerLabel, "font", "default-bold")
    DGS:dgsSetProperty(powerLabel, "textSize", {2.5, 2.5})
    DGS:dgsSetProperty(powerLabel, "wordBreak", true)
    DGS:dgsSetProperty(powerLabel, "alignment", {"center", "bottom"})

    local progress = DGS:dgsCreateProgressBar(0, powerLabelHeight + spacing, width, progressHeight, false, container)
    DGS:dgsProgressBarSetStyle(progress, "normal")
    DGS:dgsSetProperty(progress, "barColor", tocolor(100, 200, 100, 200))
    DGS:dgsSetProperty(progress, "bgColor", tocolor(0, 0, 0, 150))

    local playerLabel = DGS:dgsCreateLabel(0, powerLabelHeight + progressHeight + spacing * 2, width, playerLabelHeight, "", false, container)
    DGS:dgsSetProperty(playerLabel, "font", "default-bold")
    DGS:dgsSetProperty(playerLabel, "textSize", {1.0, 1.0})
    DGS:dgsSetProperty(playerLabel, "color", tocolor(102, 204, 255, 255))
    DGS:dgsSetProperty(playerLabel, "alignment", {"center", "top"})

    activeEffectUI = {
        container = container,
        powerLabel = powerLabel,
        progress = progress,
        playerLabel = playerLabel
    }

    -- Warning UI
    local warnWidth = 300
    local warnIconSize = 64
    local warnLabelHeight = 40
    local warnTotalHeight = warnIconSize + warnLabelHeight + 10
    
    local warnContainer = DGS:dgsCreateImage(20, containerY - warnTotalHeight - 20, warnWidth, warnTotalHeight, nil, false)
    DGS:dgsSetProperty(warnContainer, "color", tocolor(0, 0, 0, 0))
    DGS:dgsSetVisible(warnContainer, false)

    local warnIcon = DGS:dgsCreateImage((warnWidth - warnIconSize) / 2, 0, warnIconSize, warnIconSize, "img/alert.png", false, warnContainer)
    
    local warnLabel = DGS:dgsCreateLabel(0, warnIconSize + 10, warnWidth, warnLabelHeight, "", false, warnContainer)
    DGS:dgsSetProperty(warnLabel, "font", "default-bold")
    DGS:dgsSetProperty(warnLabel, "textSize", {1.5, 1.5})
    DGS:dgsSetProperty(warnLabel, "alignment", {"center", "top"})
    DGS:dgsSetProperty(warnLabel, "color", tocolor(255, 50, 50, 255))

    warningUI = {
        container = warnContainer,
        icon = warnIcon,
        label = warnLabel
    }
end

local function updateCard(index, powerupId, isLocked)
    local card = cardElements[index]
    if not card then return end
    
    if not powerupId then
        DGS:dgsSetVisible(card.bg, false)
        return
    end

    local config = getTemporaryPowerupConfig(powerupId)
    if not config then
        DGS:dgsSetVisible(card.bg, false)
        return
    end

    DGS:dgsSetVisible(card.bg, true)
    DGS:dgsSetText(card.name, config.name or "Unknown")
    DGS:dgsSetText(card.description, config.description or "")
    
    local texture = getIconTexture(config.iconPath)
    if texture then
        DGS:dgsSetVisible(card.icon, true)
        DGS:dgsImageSetImage(card.icon, texture)
    else
        DGS:dgsSetVisible(card.icon, false)
    end

    if index == 1 then
        DGS:dgsSetAlpha(card.bg, 1.0)
        DGS:dgsSetVisible(card.nextLabel, false)
        DGS:dgsSetVisible(card.lockedLabel, isLocked)
        
        -- Feedback refinement: hide description and dim other elements when locked
        DGS:dgsSetVisible(card.description, not isLocked)
        local contentAlpha = isLocked and 0.4 or 1.0
        DGS:dgsSetAlpha(card.name, contentAlpha)
        DGS:dgsSetAlpha(card.icon, contentAlpha)
    else
        DGS:dgsSetAlpha(card.bg, 1.0)
        DGS:dgsSetVisible(card.nextLabel, true)
        DGS:dgsSetVisible(card.lockedLabel, false)
        DGS:dgsSetVisible(card.description, true)
        DGS:dgsSetAlpha(card.name, 1.0)
        DGS:dgsSetAlpha(card.icon, 1.0)
    end
end

local function updateQueueUI()
    if #cardElements == 0 then initUI() end
    
    local isAnyPowerActive = next(activeEffects) ~= nil
    
    if playerPowerupQueue[1] ~= lastQueueIds[1] or isAnyPowerActive ~= lastLockState then
        updateCard(1, playerPowerupQueue[1], isAnyPowerActive)
        lastQueueIds[1] = playerPowerupQueue[1]
        lastLockState = isAnyPowerActive
    end
    
    if playerPowerupQueue[2] ~= lastQueueIds[2] then
        updateCard(2, playerPowerupQueue[2])
        lastQueueIds[2] = playerPowerupQueue[2]
    end
end

local function updateActiveEffectsUI()
    local currentTime = getTickCount()
    
    -- Handle Warning UI
    if warningEffect then
        if warningEffect.endTime > currentTime then
            if not warningUI then initUI() end
            DGS:dgsSetVisible(warningUI.container, true)
            
            local timeLeft = math.ceil((warningEffect.endTime - currentTime) / 1000)
            DGS:dgsSetText(warningUI.label, "WARNING: " .. warningEffect.name .. " in " .. timeLeft .. "s")
            
            -- Flash icon
            local alpha = (math.sin(currentTime / 150) + 1) / 2
            DGS:dgsSetAlpha(warningUI.icon, 0.2 + (alpha * 0.8))
        else
            warningEffect = nil
            if warningUI then DGS:dgsSetVisible(warningUI.container, false) end
        end
    elseif warningUI then
        DGS:dgsSetVisible(warningUI.container, false)
    end

    local activeEffect = nil
    -- Since only one power is active at a time, we just pick the first valid one
    for id, effect in pairs(activeEffects) do
        if effect.endTime > currentTime then
            activeEffect = effect
            break
        else
            activeEffects[id] = nil
        end
    end

    if activeEffect then
        if not activeEffectUI then initUI() end
        
        DGS:dgsSetVisible(activeEffectUI.container, true)
        DGS:dgsSetText(activeEffectUI.powerLabel, activeEffect.name)
        DGS:dgsSetText(activeEffectUI.playerLabel, activeEffect.playerName)
        
        local timeLeft = activeEffect.endTime - currentTime
        local progressValue = (timeLeft / activeEffect.duration) * 100
        DGS:dgsProgressBarSetProgress(activeEffectUI.progress, progressValue)
    else
        if activeEffectUI then
            DGS:dgsSetVisible(activeEffectUI.container, false)
        end
    end
end

-- Event handler for receiving queue updates from the server
addEvent("onTempPowerupQueueUpdateClient", true)
addEventHandler("onTempPowerupQueueUpdateClient", root, function(newQueue)
    playerPowerupQueue = newQueue
    updateQueueUI()
end)

-- Event handler for warning notifications
addEvent("onTempPowerupWarningClient", true)
addEventHandler("onTempPowerupWarningClient", root, function(targetPlayer, powerupId, name, duration)
    local playerName = isElement(targetPlayer) and getPlayerName(targetPlayer) or "Unknown"
    warningEffect = {
        playerName = playerName,
        name = name,
        endTime = getTickCount() + (duration * 1000),
        duration = duration * 1000
    }
end)

-- Event handler for active power-up notifications
addEvent("onTempPowerupActivatedClient", true)
addEventHandler("onTempPowerupActivatedClient", root, function(playerName, powerupId, name, duration)
    if not duration or duration <= 0 then return end
    
    -- Clear warning when effect starts
    warningEffect = nil
    if warningUI then DGS:dgsSetVisible(warningUI.container, false) end

    -- Only one active effect allowed at a time for UI simplicity as per global lock
    activeEffects = {} 
    
    local id = playerName .. "_" .. powerupId .. "_" .. getTickCount()
    activeEffects[id] = {
        playerName = playerName,
        name = name,
        duration = duration * 1000,
        endTime = getTickCount() + (duration * 1000)
    }
end)

-- Event handler for resetting temporary power-ups (e.g. on round restart)
addEvent("onTempPowerupResetClient", true)
addEventHandler("onTempPowerupResetClient", root, function()
    activeEffects = {}
    warningEffect = nil
    if activeEffectUI then
        DGS:dgsSetVisible(activeEffectUI.container, false)
    end
    if warningUI then
        DGS:dgsSetVisible(warningUI.container, false)
    end
    updateQueueUI()
end)

local function precacheIcons()
    local ids = getAllTemporaryPowerupIds()
    for _, id in ipairs(ids) do
        local config = getTemporaryPowerupConfig(id)
        if config and config.iconPath then
            getIconTexture(config.iconPath)
        end
    end
end

-- Initialize UI on start or when needed
addEventHandler("onClientResourceStart", resourceRoot, function()
    initUI()
    -- Periodic check to handle metadata sync delays or queue state
    setTimer(updateQueueUI, 1000, 0)
    -- Pre-cache icons after a short delay to allow metadata sync
    setTimer(precacheIcons, 2000, 1)
end)

-- Update active effects progress and positions
addEventHandler("onClientRender", root, function()
    updateActiveEffectsUI()
end)
