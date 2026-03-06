-- ctg/client/temp_power_ui.lua
-- Client-side module for displaying the player's temporary power-up queue.

local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()
local UI_BASE_X = SCREEN_WIDTH / 2 -- Center horizontally
local UI_BASE_Y = SCREEN_HEIGHT - 120 -- Position from bottom
local CARD_WIDTH = 200
local CARD_HEIGHT = 60
local CARD_SPACING = 10
local CARD_BACKGROUND_COLOR = tocolor(0, 0, 0, 180) -- Semi-transparent black
local CARD_TEXT_COLOR = tocolor(255, 255, 255, 255) -- White
local CARD_DESCRIPTION_COLOR = tocolor(200, 200, 200, 255) -- Grey-ish white
local CARD_BORDER_COLOR = tocolor(255, 255, 255, 200)

local playerPowerupQueue = {} -- The client's current temporary power-up queue
local tempPowerupConfig = require("ctg.shared.temp_powers_config") -- Load shared config

-- Function to draw a single power-up card
local function drawPowerupCard(powerupId, x, y, alphaMultiplier, isQueueItem)
    if not powerupId then return end

    local config = tempPowerupConfig[powerupId]
    if not config then return end

    local bgAlpha = math.floor(180 * alphaMultiplier)
    local borderAlpha = math.floor(200 * alphaMultiplier)
    local textAlpha = math.floor(255 * alphaMultiplier)
    local descAlpha = math.floor(200 * alphaMultiplier)

    -- Background (card)
    dxDrawRectangle(x, y, CARD_WIDTH, CARD_HEIGHT, tocolor(0, 0, 0, bgAlpha))

    -- Border
    dxDrawRectangle(x, y, CARD_WIDTH, 2, tocolor(255, 255, 255, borderAlpha)) -- Top
    dxDrawRectangle(x, y + CARD_HEIGHT - 2, CARD_WIDTH, 2, tocolor(255, 255, 255, borderAlpha)) -- Bottom
    dxDrawRectangle(x, y + 2, 2, CARD_HEIGHT - 4, tocolor(255, 255, 255, borderAlpha)) -- Left
    dxDrawRectangle(x + CARD_WIDTH - 2, y + 2, 2, CARD_HEIGHT - 4, tocolor(255, 255, 255, borderAlpha)) -- Right

    local textX = x + 10 -- Offset for text
    local textY = y + 5
    local descY = y + CARD_HEIGHT / 2 + 5

    -- Power-up Name
    dxDrawText(config.name, textX, textY, x + CARD_WIDTH - 10, y + CARD_HEIGHT / 2, tocolor(255, 255, 255, textAlpha), 1.0, "default-bold", "left", "top", false, false, false, true)

    -- Power-up Description (who it affects)
    dxDrawText(config.description, textX, descY, x + CARD_WIDTH - 10, y + CARD_HEIGHT - 5, tocolor(200, 200, 200, descAlpha), 0.8, "default", "left", "top", false, false, false, true)

    -- Optional: Icon
    if config.iconPath and fileExists(config.iconPath) then
        local iconSize = CARD_HEIGHT - 10
        dxDrawImage(x + CARD_WIDTH - iconSize - 5, y + 5, iconSize, iconSize, config.iconPath, 0, 0, 0, tocolor(255, 255, 255, textAlpha))
    end

    if isQueueItem then
        -- Draw "NEXT" text for the second item
        dxDrawText("NEXT", x + CARD_WIDTH / 2 - 20, y - 20, x + CARD_WIDTH / 2 + 20, y - 5, tocolor(255, 255, 255, textAlpha), 0.7, "default-bold", "center", "center")
    end
end

-- Render function to draw all temporary power-ups
local function renderTemporaryPowerups()
    if #playerPowerupQueue == 0 then return end

    -- Calculate position for the first card (current power-up)
    local currentCardX = UI_BASE_X - CARD_WIDTH / 2
    local currentCardY = UI_BASE_Y

    -- Draw the first item (current power-up)
    drawPowerupCard(playerPowerupQueue[1], currentCardX, currentCardY, 1.0, false)

    -- If there's a second item, draw it slightly behind and faded
    if #playerPowerupQueue >= 2 then
        local nextCardX = currentCardX + 5 -- Slight offset to the right
        local nextCardY = currentCardY - 20 -- Slight offset upwards
        drawPowerupCard(playerPowerupQueue[2], nextCardX, nextCardY, 0.6, true) -- Faded and marked as queue item
    end
end

-- Event handler for receiving queue updates from the server
addEvent("onTempPowerupQueueUpdateClient", true)
addEventHandler("onTempPowerupQueueUpdateClient", root, function(newQueue)
    playerPowerupQueue = newQueue
    outputChatBox("Temporary power-up queue updated: " .. tostring(table.concat(newQueue, ", ")), 0, 255, 255)
end)

-- Add the render function to the client's rendering loop
addEventHandler("onClientRender", root, renderTemporaryPowerups)
