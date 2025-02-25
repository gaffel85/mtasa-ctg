local powerwindow = nil
local scrollpane = nil

local dummyData = {
    active = {
        { key = "nitro", bindKey = "lctrl" },
        { key = "teleport", bindKey = "X" },
        --{ key = "busses", bindKey = "C" },
        --{ key = "waterLevel", bindKey = "R" },
        { key = "canon", bindKey = "C" },
        --{ key = "plane", bindKey = "P" },
        --{ key = "cinematic", bindKey = "N" },
    },
    wanted = {},
    owned = {
        "nitro",
        "teleport",
        "canon",
        "superCar",
    },
    all = {
        "nitro",
        "teleport",
        "busses",
        "waterLevel",
        "canon",
        "plane",
        "cinematic",
        "superCar",
    }
}

function getPowerUp(key)
    return {
        key = key,
        name = "The "..key.." power",
        desc = "This is a description of "..key..". It can be very long",
        cooldown = 20,
        duration = 10,
        charges = -1,
        initCooldown = 10,
        allowedGoldCarrier = false,
    }
end

function 

function isOwned(key)
    for k, v in ipairs(dummyData.owned) do
        if v == key then
            return true
        end
    end
    return false
end

function createPowerBox(powerUp, isOwned, row, col)
    powerbox = guiCreateButton(0.01, 0.10, 0.16, 0.24, "", true, scrollpane)

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
    description = guiCreateLabel(0.01, 0.09, 0.14, 0.14, powerUp.name, true, powerbox)

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

addEventHandler("onClientResourceStart", resourceRoot,
    function()
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

        local row = 1
        local col = 1
        for k, v in ipairs(dummyData.all) do
            local powerUp = getPowerUp(v)
            local isOwned = isOwned(v)
            createPowerBox(powerUp, isOwned, row, col)
            col = col + 1
            if col > 5 then
                col = 1
                row = row + 1
            end
        end
        
    end
)