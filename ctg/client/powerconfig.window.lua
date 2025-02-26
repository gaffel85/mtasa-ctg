local powerwindow = nil
local scrollpane = nil
local doneButton = nil
local powerUps = nil
local powerConfig = nil

function getPowerUp(key)
    for k, v in ipairs(powerUps) do
        if v.key == key then
            return v
        end
    end
    return nil
end

function loadPowerUps()
    triggerServerEvent("loadPowerUpsServer", resourceRoot)
end

function loadPowerConfig()
    triggerServerEvent("loadPowerupsConfigServer", resourceRoot)
end

function onPowerupsConfigLoaded(config)
    powerConfig = config
    populateBoxes()
end
addEvent("onPowerupsConfigLoadedClient", true)
addEventHandler("onPowerupsConfigLoadedClient", resourceRoot, onPowerupsConfigLoaded)


function onPowerupsLoaded(powers)
    powerUps = powers
    populateBoxes()
end
addEvent("onPowerupsLoadedClient", true)
addEventHandler("onPowerupsLoadedClient", resourceRoot, onPowerupsLoaded)

function isOwned(key)
    for k, v in ipairs(powerConfig.owned) do
        if v == key then
            return true
        end
    end
    return false
end

function createPowerBox(powerUp, isOwned, row, col)
    local xBox = 0.01 + (0.18 * (col - 1))
    local yBox = 0.01 + (0.30 * (row - 1))
    powerbox = guiCreateButton(xBox, yBox, 0.16, 0.24, "", true, scrollpane)

    powerTitle = guiCreateLabel(0.06, 0.05, 0.87, 0.08, powerUp.name, true, powerbox)
    guiSetFont(powerTitle, "clear-normal")
    guiLabelSetHorizontalAlign(powerTitle, "center", false)

    durationTitle = guiCreateLabel(0.06, 0.13, 0.87, 0.05, "Duration: ", true, powerbox)
    cooldownTitle = guiCreateLabel(0.06, 0.18, 0.87, 0.05, "Cooldown: ", true, powerbox)
    usedAsGoldCarrierTitle = guiCreateLabel(0.42, 0.13, 0.30, 0.16, "Can be used when carrying gold:", true, powerbox)
    guiSetFont(durationTitle, "default-bold-small")
    guiSetFont(cooldownTitle, "default-bold-small")
    guiSetFont(usedAsGoldCarrierTitle, "default-bold-small")
    guiLabelSetHorizontalAlign(usedAsGoldCarrierTitle, "right", true)
    guiLabelSetColor (durationTitle, 0, 255, 0)

    if not isOwned then
        unlockButton = guiCreateButton(0.71, 0.86, 0.23, 0.10, "Unlock", true, powerbox)
    else
        bindXButton = guiCreateButton(0.05, 0.86, 0.28, 0.10, "Bind X", true, powerbox)
        bindCButton = guiCreateButton(0.06, 0.24, 0.05, 0.03, "Bind C", true, powerbox)
    end

    durationValue = guiCreateLabel(0.24, 0.07, 0.24, 0.93, powerUp.duration.."s", true, durationTitle)
    cooldownValue = guiCreateLabel(0.25, 0.00, 0.16, 1.00, powerUp.cooldown.."s", true, cooldownTitle)
    local canBeYsedAsGoldCarrier = powerUp.allowedGoldCarrier and "Yes" or "No"
    usedAsGoldCarrierValue = guiCreateLabel(0.76, 0.13, 0.18, 0.16, canBeYsedAsGoldCarrier, true, powerbox)
    description = guiCreateLabel(0.06, 0.35, 0.88, 0.5, powerUp.desc, true, powerbox)

    guiLabelSetHorizontalAlign(description, "left", true)

    return {
        powerUp = powerUp,
        box = powerbox,
        title = powerTitle,
        duration = durationValue,
        cooldown = cooldownValue,
        bindX = bindXButton,
        bindC = bindCButton,
        unlock = unlockButton,
        usedAsGoldCarrier = usedAsGoldCarrierValue,
        description = description
    }
end

function populateBoxes()
    if not powerUps or not powerConfig then
        return
    end

    local row = 1
    local col = 1
    for k, powerUp in ipairs(powerUps) do
        local isOwned = isOwned(powerUp.key)
        outputConsole("Power up: "..powerUp.key.." owned: "..tostring(isOwned))
        createPowerBox(powerUp, isOwned, row, col)
        col = col + 1
        if col > 5 then
            col = 1
            row = row + 1
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        outputConsole("----------------------------")

        powerwindow = guiCreateWindow(0.01, 0.02, 0.98, 0.95, "Choose power-ups", true)
        guiWindowSetSizable(powerwindow, false)
        guiSetAlpha(powerwindow, 0.93)

        scrollpane = guiCreateScrollPane(0.01, 0.09, 0.99, 0.89, true, powerwindow)
        boundPowerBox = guiCreateButton(323, 30, 211, 66, "", false, powerwindow)

        boundPowerKey = guiCreateButton(0.04, 0.14, 0.27, 0.71, "lctrl", true, boundPowerBox)
        boundPowerName = guiCreateLabel(0.32, 0.15, 0.63, 0.70, "Power name", true, boundPowerBox)
        guiLabelSetHorizontalAlign(boundPowerName, "center", false)
        guiLabelSetVerticalAlign(boundPowerName, "center")

        doneButton = guiCreateButton(0.93, 0.02, 0.06, 0.05, "Done", true, powerwindow)

        guiSetInputEnabled(true)
		showCursor(true)

        addEventHandler("onClientGUIClick", doneButton, function()
            guiSetInputEnabled(false)
		    showCursor(false)
            guiSetVisible(powerwindow, false)
        end, false)

        if powerUps and powerConfig then
            populateBoxes()
        else
            loadPowerUps()
            loadPowerConfig()
        end
        
    end
)