local powerwindow = nil
local scrollpane = nil
local doneButton = nil
local powerUps = nil
local powerConfig = nil
local powerUpBoxes = {}
local boundPowerBoxes = {}

function getPowerUp(key)
    for k, v in ipairs(powerUps) do
        if v.key == key then
            return v
        end
    end
    return nil
end

function savePowerConfig()
    triggerServerEvent("setConfigFromClient", resourceRoot, powerConfig)
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

function openWindowFromServer(config)
    powerConfig = config
    populateBoxes()
    openWindow()
end
addEvent("onOpenPowerConfigWindowClient", true)
addEventHandler("onOpenPowerConfigWindowClient", resourceRoot, openWindowFromServer)

function unlock(powerKey)
    outputConsole("unlock "..powerKey)
    table.insert(powerConfig.owned, powerKey)
    savePowerConfig()
    populateBoxes()
end

function bindWithKey(powerKey, bindKey)
    outputConsole("bindWithKey "..powerKey.." "..bindKey)
    for k, v in ipairs(powerConfig.owned) do
        if v == powerKey then

            -- remove previous binding with same key
            for k, activePower in ipairs(powerConfig.active) do
                if activePower.bindKey == bindKey then
                    table.remove(powerConfig.active, k)
                    break
                end
            end

            table.insert(powerConfig.active, { key = powerKey, bindKey = bindKey })

            savePowerConfig()
            populateBoxes()
            return
        end
    end
end


function isOwned(key)
    for k, v in ipairs(powerConfig.owned) do
        if v == key then
            return true
        end
    end
    return false
end

function createActivePowerBox(powerUp, boundKey, col)
    local xBox = 0.17 + (0.18 * (col - 1))
    local yBox = 0.03

    boundPowerBox = guiCreateButton(xBox, yBox, 0.16, 0.06, "", true, powerwindow)

    boundPowerKey = guiCreateButton(0.04, 0.14, 0.27, 0.71, boundKey, true, boundPowerBox)
    guiSetAlpha(boundPowerKey, 0.99)
    guiBringToFront(boundPowerKey)

    boundPowerName = guiCreateLabel(0.32, 0.15, 0.63, 0.70, powerUp.name, true, boundPowerBox)
    guiLabelSetHorizontalAlign(boundPowerName, "center", false)
    guiLabelSetVerticalAlign(boundPowerName, "center")

    guiSetAlpha(boundPowerBox, 0.99)
    guiBringToFront(boundPowerBox)

    return {
        box = boundPowerBox,
        key = boundPowerKey,
        name = boundPowerName
    }
end

function createPowerBox(powerUp, isOwned, row, col)
    local xBox = 0.01 + (0.18 * (col - 1))
    local yBox = 0.01 + (0.30 * (row - 1))
    powerbox = guiCreateButton(xBox, yBox, 0.16, 0.24, "", true, scrollpane)

    powerTitle = guiCreateLabel(0.06, 0.05, 0.87, 0.08, powerUp.name, true, powerbox)
    guiSetFont(powerTitle, "clear-normal")
    guiLabelSetHorizontalAlign(powerTitle, "center", false)

    durationTitle = guiCreateLabel(0.06, 0.13, 0.87, 0.07, "Duration: ", true, powerbox)
    cooldownTitle = guiCreateLabel(0.06, 0.18, 0.87, 0.07, "Cooldown: ", true, powerbox)
    usedAsGoldCarrierTitle = guiCreateLabel(0.42, 0.13, 0.30, 0.20, "Can be used when carrying gold:", true, powerbox)
    guiSetFont(durationTitle, "default-bold-small")
    guiSetFont(cooldownTitle, "default-bold-small")
    guiSetFont(usedAsGoldCarrierTitle, "default-bold-small")
    guiLabelSetHorizontalAlign(usedAsGoldCarrierTitle, "right", true)
    guiLabelSetColor (durationTitle, 0, 255, 0)

    if not isOwned then
        unlockButton = guiCreateButton(0.71, 0.86, 0.23, 0.10, "Unlock", true, powerbox)
        addEventHandler("onClientGUIClick", unlockButton, function()
            unlock(powerUp.key)
        end, false)
    else
        bindXButton = guiCreateButton(0.05, 0.86, 0.28, 0.10, "Bind X", true, powerbox)
        bindCButton = guiCreateButton(0.46, 0.86, 0.28, 0.10, "Bind C", true, powerbox)
        addEventHandler("onClientGUIClick", bindXButton, function()
            bindWithKey(powerUp.key, "X")
        end, false)
        addEventHandler("onClientGUIClick", bindCButton, function()
            bindWithKey(powerUp.key, "C")
        end, false)
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

    for k, box in ipairs(powerUpBoxes) do
        if isElement(box.box) then
            destroyElement(box.box)
        end
    end

    for k, box in ipairs(boundPowerBoxes) do
        if isElement(box.box) then
            destroyElement(box.box)
        end
    end

    local row = 1
    local col = 1
    for k, powerUp in ipairs(powerUps) do
        local isOwned = isOwned(powerUp.key)
        outputConsole("Power up: "..powerUp.key.." owned: "..tostring(isOwned))
        local box = createPowerBox(powerUp, isOwned, row, col)
        table.insert(powerUpBoxes, box)
        col = col + 1
        if col > 5 then
            col = 1
            row = row + 1
        end
    end

    col = 1
    for k, activePower in ipairs(powerConfig.active) do
        local powerUp = getPowerUp(activePower.key)
        outputConsole("1111Active power up: "..activePower.key)
        if powerUp then
            outputConsole("---Active power up: "..powerUp.key.." "..activePower.bindKey)
            local box = createActivePowerBox(powerUp, activePower.bindKey, col)
            table.insert(boundPowerBoxes, box)
            col = col + 1
        end
    end
end

function openWindow()
    guiSetInputEnabled(true)
    showCursor(true)
    guiSetVisible(powerwindow, true)

    addEventHandler("onClientGUIClick", doneButton, function()
        guiSetInputEnabled(false)
        showCursor(false)
        guiSetVisible(powerwindow, false)
    end, false)

    if powerUps and powerConfig then
        populateBoxes()
    else
        loadPowerUps()
    end

    loadPowerConfig()
end

function toggleWindow()
    outputChatBox("toggleWindow")
    if guiGetVisible(powerwindow) then
        guiSetInputEnabled(false)
        showCursor(false)
        guiSetVisible(powerwindow, false)
    else
        openWindow()
    end
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        outputConsole("----------------------------")

        powerwindow = guiCreateWindow(0.01, 0.02, 0.98, 0.95, "Choose power-ups", true)
        guiWindowSetSizable(powerwindow, false)
        guiSetAlpha(powerwindow, 0.93)

        scrollpane = guiCreateScrollPane(0.01, 0.2, 0.99, 0.79, true, powerwindow)

        doneButton = guiCreateButton(0.93, 0.02, 0.06, 0.05, "Done", true, powerwindow)
        guiSetVisible(powerwindow, false)
        --openWindow()  
    end
)

function bindConfigPowerKeys(player)
    outputChatBox("bindConfigPowerKeys")
    bindKey ( "F3", "up", toggleWindow )
end

function unbindConfigPowerKeys(player)
    unbindKey ( "F3" )
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
    outputChatBox("onClientResourceStart3333"..inspect(source))
    bindConfigPowerKeys(source)
end)
