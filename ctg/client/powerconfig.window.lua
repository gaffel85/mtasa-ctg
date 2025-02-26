local powerwindow = nil
local scrollpane = nil

function createPowerBox()
    powerbox = guiCreateButton(0.01, 0.10, 0.16, 0.24, "", true, scrollpane)

    powerTitle = guiCreateLabel(0.06, 0.05, 0.87, 0.08, "Power Name", true, powerbox)
    guiSetFont(powerTitle, "clear-normal")
    guiLabelSetHorizontalAlign(powerTitle, "center", false)
    unlockButton = guiCreateButton(0.71, 0.86, 0.23, 0.10, "Unlock", true, powerbox)
    durationTitle = guiCreateLabel(0.06, 0.13, 0.87, 0.05, "Duration: ", true, powerbox)
    guiSetFont(durationTitle, "default-bold-small")

    durationValue = guiCreateLabel(0.24, 0.07, 0.24, 0.93, "10s", true, durationTitle)

    GUIEditor.label[1] = guiCreateLabel(649, -58, 255, 15, "Duration: ", false, powerbox)
    guiSetFont(GUIEditor.label[1], "default-bold-small")
    cooldownTitle = guiCreateLabel(0.06, 0.18, 0.87, 0.05, "Cooldown: ", true, powerbox)
    guiSetFont(cooldownTitle, "default-bold-small")

    cooldownValue = guiCreateLabel(0.25, 0.00, 0.16, 1.00, "20s", true, cooldownTitle)

    bindXButton = guiCreateButton(0.05, 0.86, 0.28, 0.10, "Bind X", true, powerbox)
    usedAsGoldCarrierTitle = guiCreateLabel(0.42, 0.13, 0.30, 0.16, "Can be used when carrying gold:", true, powerbox)
    guiSetFont(usedAsGoldCarrierTitle, "default-bold-small")
    guiLabelSetHorizontalAlign(usedAsGoldCarrierTitle, "right", true)
    usedAsGoldCarrierValue = guiCreateLabel(0.76, 0.13, 0.18, 0.16, "Yes", true, powerbox)

    description = guiCreateLabel(0.01, 0.09, 0.14, 0.14, "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.", true, powerbox)
    guiLabelSetHorizontalAlign(description, "left", true)
    bindCButton = guiCreateButton(0.06, 0.24, 0.05, 0.03, "Bind C", true, powerbox)
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

        createPowerBox()

        
    end
)