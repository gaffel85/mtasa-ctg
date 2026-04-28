-- ctg/client/keybinds.ui.lua
-- Client-side UI to display special keybinds on the left side of the screen.

local DGS = exports.dgs

-- List of keybinds to show. Defined in an array for easy modification.
local KEYBINDS = {
    {key = "F1",  desc = "Join Team 1"},
    {key = "F2",  desc = "Join Team 2"},
    {key = "F4",  desc = "Vote for Next Vehicle"},
    {key = "R",   desc = "Reset Vehicle"},
    {key = "G",   desc = "Drop Gold"},
    {key = "Z",   desc = "Catch up (if available)"},
    {key = "X",   desc = "Use Temporary Powerup"},
    {key = "LMB", desc = "Nitro"},
    {key = "RMB", desc = "Jump"},
    {key = "C",   desc = "Canon Ball"},
}

-- UI Configuration
local screenW, screenH = guiGetScreenSize()
local ITEM_HEIGHT = 28
local ITEM_SPACING = 10
local KEY_BOX_WIDTH = 45
local KEY_TEXT_SPACING = 12
local START_X = 25
local TEXT_COLOR = tocolor(220, 220, 220, 255)
local KEY_BG_COLOR = tocolor(40, 40, 40, 180) -- Semi-transparent grey
local KEY_BORDER_COLOR = tocolor(200, 200, 200, 60) -- Very subtle border

local container = nil

local function initKeybindsUI()
    if not DGS then 
        outputDebugString("Keybinds UI: DGS export not found, retrying...")
        setTimer(function()
            DGS = exports.dgs
            if DGS then initKeybindsUI() end
        end, 500, 1)
        return 
    end

    local totalHeight = #KEYBINDS * (ITEM_HEIGHT + ITEM_SPACING) - ITEM_SPACING
    -- Center the list vertically on the left side
    local startY = (screenH - totalHeight) / 2
    
    -- Main container for all keybind entries
    container = DGS:dgsCreateImage(START_X, startY, 400, totalHeight, nil, false)
    DGS:dgsSetProperty(container, "color", tocolor(0, 0, 0, 0))

    for i, bind in ipairs(KEYBINDS) do
        local y = (i - 1) * (ITEM_HEIGHT + ITEM_SPACING)
        
        -- Create a rounded rectangle with a very thin/subtle border
        -- Parameters: radius, isRelative, color, borderColor, borderSize, isAntialias
        local rndRect = DGS:dgsCreateRoundRect(0.15, true, KEY_BG_COLOR, KEY_BORDER_COLOR, 0.5, true)
        
        -- The "Key" Box
        local keyBox = DGS:dgsCreateImage(0, y, KEY_BOX_WIDTH, ITEM_HEIGHT, rndRect, false, container)
        
        local keyLabel = DGS:dgsCreateLabel(0, 0, 1, 1, bind.key, true, keyBox)
        DGS:dgsSetProperty(keyLabel, "alignment", {"center", "center"})
        DGS:dgsSetProperty(keyLabel, "font", "default-bold")
        DGS:dgsSetProperty(keyLabel, "textSize", {0.9, 0.9})
        DGS:dgsSetProperty(keyLabel, "textColor", tocolor(255, 255, 255, 255))
        DGS:dgsSetProperty(keyLabel, "shadow", {1, 1, tocolor(0, 0, 0, 200), true})

        -- The Function Description
        local descLabel = DGS:dgsCreateLabel(KEY_BOX_WIDTH + KEY_TEXT_SPACING, y, 300, ITEM_HEIGHT, bind.desc, false, container)
        DGS:dgsSetProperty(descLabel, "alignment", {"left", "center"})
        DGS:dgsSetProperty(descLabel, "font", "default")
        DGS:dgsSetProperty(descLabel, "textSize", {1.0, 1.0})
        DGS:dgsSetProperty(descLabel, "textColor", TEXT_COLOR)
        
        -- Shadow for readability
        DGS:dgsSetProperty(descLabel, "shadow", {1, 1, tocolor(0, 0, 0, 255), true})
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    -- Small delay to ensure DGS is fully ready
    setTimer(initKeybindsUI, 500, 1)
end)
