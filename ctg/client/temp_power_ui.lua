-- ctg/client/temp_power_ui.lua
-- Client-side module for displaying the player's temporary power-up queue.

local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()
local UI_BASE_X = SCREEN_WIDTH / 2 -- Center horizontally
local UI_BASE_Y = SCREEN_HEIGHT - 250 -- Position from bottom, raised to accommodate larger cards
local CARD_WIDTH = 400
local CARD_HEIGHT = 120
local CARD_SPACING = 20
local CARD_BACKGROUND_COLOR = tocolor(0, 0, 0, 255) -- Opaque black
local CARD_TEXT_COLOR = tocolor(255, 255, 255, 255) -- White
local CARD_DESCRIPTION_COLOR = tocolor(200, 200, 200, 255) -- Grey-ish white
local CARD_BORDER_COLOR = tocolor(255, 255, 255, 255)

local playerPowerupQueue = {} -- The client's current temporary power-up queue
local activeEffects = {} -- Stores active temporary power-up effects for progress bars

-- Function to draw a single power-up card
local function drawPowerupCard(powerupId, x, y, alphaMultiplier, isQueueItem)
    if not powerupId then return end

    local config = getTemporaryPowerupConfig(powerupId)
    if not config then return end

    local bgAlpha = math.floor(255 * alphaMultiplier)
    local borderAlpha = math.floor(255 * alphaMultiplier)
    local textAlpha = math.floor(255 * alphaMultiplier)
    local descAlpha = math.floor(200 * alphaMultiplier)

    -- Background (card)
    dxDrawRectangle(x, y, CARD_WIDTH, CARD_HEIGHT, tocolor(0, 0, 0, bgAlpha))

    -- Border
    dxDrawRectangle(x, y, CARD_WIDTH, 2, tocolor(255, 255, 255, borderAlpha)) -- Top
    dxDrawRectangle(x, y + CARD_HEIGHT - 2, CARD_WIDTH, 2, tocolor(255, 255, 255, borderAlpha)) -- Bottom
    dxDrawRectangle(x, y + 2, 2, CARD_HEIGHT - 4, tocolor(255, 255, 255, borderAlpha)) -- Left
    dxDrawRectangle(x + CARD_WIDTH - 2, y + 2, 2, CARD_HEIGHT - 4, tocolor(255, 255, 255, borderAlpha)) -- Right

    local iconSize = CARD_HEIGHT - 20
    local textX = x + 15 -- Offset for text
    local textWidth = CARD_WIDTH - 30
    
    -- Optional: Icon
    if config.iconPath and fileExists(config.iconPath) then
        dxDrawImage(x + CARD_WIDTH - iconSize - 10, y + 10, iconSize, iconSize, config.iconPath, 0, 0, 0, tocolor(255, 255, 255, textAlpha))
        textWidth = textWidth - iconSize - 10
    end

    local textY = y + 10
    local descY = y + 45

    -- Power-up Name
    dxDrawText(config.name, textX, textY, textX + textWidth, y + 40, tocolor(255, 255, 255, textAlpha), 1.5, "default-bold", "left", "top", false, false, false, true)

    -- Power-up Description (who it affects)
    dxDrawText(config.description, textX, descY, textX + textWidth, y + CARD_HEIGHT - 10, tocolor(200, 200, 200, descAlpha), 1.2, "default", "left", "top", true, true, false, true)

    if isQueueItem then
        -- Draw "NEXT" text for the second item
        dxDrawText("NEXT", x + CARD_WIDTH / 2 - 20, y - 30, x + CARD_WIDTH / 2 + 20, y - 5, tocolor(255, 255, 255, textAlpha), 1.0, "default-bold", "center", "center")
    end
end

-- Render function to draw active power-up effects with progress bars
local function renderActiveEffects()
    local currentTime = getTickCount()
    local startX = 20
    local startY = SCREEN_HEIGHT / 2 - 100
    local barWidth = 250
    local barHeight = 25
    local spacing = 50

    local count = 0
    for id, effect in pairs(activeEffects) do
        local timeLeft = effect.endTime - currentTime
        if timeLeft > 0 then
            local progress = timeLeft / effect.duration
            local y = startY + count * spacing

            -- Label
            dxDrawText(effect.name .. " (" .. effect.playerName .. ")", startX, y - 15, startX + barWidth, y, tocolor(255, 255, 255, 255), 1.0, "default-bold")

            -- Progress bar background
            dxDrawRectangle(startX, y, barWidth, barHeight, tocolor(0, 0, 0, 150))
            -- Progress bar foreground
            dxDrawRectangle(startX + 2, y + 2, (barWidth - 4) * progress, barHeight - 4, tocolor(100, 200, 100, 200))
            
            count = count + 1
        else
            activeEffects[id] = nil
        end
    end
end

-- Render function to draw all temporary power-ups
local function renderTemporaryPowerups()
    renderActiveEffects() -- Draw active effects first

    if #playerPowerupQueue == 0 then return end

    -- Calculate position for the first card (current power-up)
    local currentCardX = UI_BASE_X - CARD_WIDTH / 2
    local currentCardY = UI_BASE_Y

    -- Draw the first item (current power-up)
    drawPowerupCard(playerPowerupQueue[1], currentCardX, currentCardY, 1.0, false)

    -- If there's a second item, draw it slightly behind and faded
    if #playerPowerupQueue >= 2 then
        local nextCardX = currentCardX + 10 -- Slight offset to the right
        local nextCardY = currentCardY - 40 -- Slight offset upwards
        drawPowerupCard(playerPowerupQueue[2], nextCardX, nextCardY, 0.6, true) -- Faded and marked as queue item
    end
end

-- Event handler for receiving queue updates from the server
addEvent("onTempPowerupQueueUpdateClient", true)
addEventHandler("onTempPowerupQueueUpdateClient", root, function(newQueue)
    playerPowerupQueue = newQueue
end)

-- Event handler for active power-up notifications
addEvent("onTempPowerupActivatedClient", true)
addEventHandler("onTempPowerupActivatedClient", root, function(playerName, powerupId, name, duration)
    if not duration or duration <= 0 then return end
    
    local id = playerName .. "_" .. powerupId .. "_" .. getTickCount()
    activeEffects[id] = {
        playerName = playerName,
        name = name,
        duration = duration * 1000,
        endTime = getTickCount() + (duration * 1000)
    }
end)

-- Add the render function to the client's rendering loop
addEventHandler("onClientRender", root, renderTemporaryPowerups)
