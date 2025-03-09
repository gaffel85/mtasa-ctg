
GUIEditor = {
    tab = {},
    window = {},
    edit = {},
    label = {}
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        GUIEditor.window[1] = guiCreateWindow(0.01, 0.01, 0.99, 0.96, "", true)
        guiWindowSetSizable(GUIEditor.window[1], false)

        tabs = guiCreateTabPanel(0.00, 0.02, 0.99, 0.97, true, GUIEditor.window[1])

        GUIEditor.tab[1] = guiCreateTab("Constants", tabs)

        constKey = guiCreateLabel(0.01, 0.01, 0.14, 0.02, "consts.name", true, GUIEditor.tab[1])
        guiLabelSetHorizontalAlign(constKey, "right", false)
        guiLabelSetVerticalAlign(constKey, "center")
        constInput = guiCreateEdit(0.15, 0.01, 0.06, 0.02, "20", true, GUIEditor.tab[1])
        constNilToggle = guiCreateCheckBox(0.22, 0.01, 0.07, 0.02, "Nil", true, true, GUIEditor.tab[1])

        GUIEditor.tab[2] = guiCreateTab("Powers", tabs)

        powersScrollpane = guiCreateScrollPane(0.00, 0.01, 0.99, 0.98, true, GUIEditor.tab[2])

        powerKeyLabel = guiCreateLabel(0.00, 0.01, 0.08, 0.02, "power.key", true, powersScrollpane)
        guiLabelSetHorizontalAlign(powerKeyLabel, "right", false)
        guiLabelSetVerticalAlign(powerKeyLabel, "center")
        durationLabel = guiCreateLabel(0.09, 0.01, 0.03, 0.02, "Duration", true, powersScrollpane)
        guiLabelSetHorizontalAlign(durationLabel, "right", false)
        guiLabelSetVerticalAlign(durationLabel, "center")
        durationInput = guiCreateEdit(0.12, 0.01, 0.02, 0.02, "", true, powersScrollpane)


        GUIEditor.tab[3] = guiCreateTab("Players", tabs)
        GUIEditor.tab[4] = guiCreateTab("Control", tabs)


        GUIEditor.window[2] = guiCreateWindow(0.01, 0.01, 0.99, 0.96, "", true)
        guiWindowSetSizable(GUIEditor.window[2], false)

        tabs = guiCreateTabPanel(0.00, 0.02, 0.97, 0.97, true, GUIEditor.window[2])

        GUIEditor.tab[5] = guiCreateTab("Constants", tabs)

        constKey = guiCreateLabel(0.01, 0.01, 0.14, 0.02, "consts.name", true, GUIEditor.tab[5])
        guiLabelSetHorizontalAlign(constKey, "right", false)
        guiLabelSetVerticalAlign(constKey, "center")
        constInput = guiCreateEdit(0.15, 0.01, 0.06, 0.02, "20", true, GUIEditor.tab[5])
        constNilToggle = guiCreateCheckBox(0.22, 0.01, 0.07, 0.02, "Nil", false, true, GUIEditor.tab[5])

        GUIEditor.tab[6] = guiCreateTab("Powers", tabs)

        powersScrollpane = guiCreateScrollPane(0.00, 0.01, 0.99, 0.98, true, GUIEditor.tab[6])

        powerKeyLabel = guiCreateLabel(0.00, 0.01, 0.08, 0.02, "power.key", true, powersScrollpane)
        guiLabelSetHorizontalAlign(powerKeyLabel, "right", false)
        guiLabelSetVerticalAlign(powerKeyLabel, "center")
        durationLabel = guiCreateLabel(0.09, 0.01, 0.03, 0.02, "Duration", true, powersScrollpane)
        guiLabelSetHorizontalAlign(durationLabel, "right", false)
        guiLabelSetVerticalAlign(durationLabel, "center")
        durationInput = guiCreateEdit(0.12, 0.01, 0.02, 0.02, "", true, powersScrollpane)
        cooldownLabel = guiCreateLabel(0.15, 0.01, 0.03, 0.02, "Cooldown", true, powersScrollpane)
        guiLabelSetHorizontalAlign(cooldownLabel, "right", false)
        guiLabelSetVerticalAlign(cooldownLabel, "center")
        cooldownInput = guiCreateEdit(0.18, 0.01, 0.02, 0.02, "", true, powersScrollpane)


        GUIEditor.tab[7] = guiCreateTab("Players", tabs)

        GUIEditor.label[1] = guiCreateLabel(0.01, 0.02, 0.10, 0.02, "playerName", true, GUIEditor.tab[7])
        guiLabelSetHorizontalAlign(GUIEditor.label[1], "right", false)
        guiLabelSetVerticalAlign(GUIEditor.label[1], "center")
        scoreLabel = guiCreateLabel(0.11, 0.02, 0.02, 0.02, "Score", true, GUIEditor.tab[7])
        guiLabelSetHorizontalAlign(scoreLabel, "right", false)
        guiLabelSetVerticalAlign(scoreLabel, "center")
        scoreInput = guiCreateEdit(0.14, 0.02, 0.04, 0.02, "", true, GUIEditor.tab[7])
        moneyLabel = guiCreateLabel(0.18, 0.02, 0.02, 0.02, "Money", true, GUIEditor.tab[7])
        guiLabelSetHorizontalAlign(moneyLabel, "right", false)
        guiLabelSetVerticalAlign(moneyLabel, "center")
        moneyInput = guiCreateEdit(0.21, 0.02, 0.04, 0.02, "", true, GUIEditor.tab[7])
        GUIEditor.label[2] = guiCreateLabel(0.25, 0.02, 0.02, 0.02, "Rank", true, GUIEditor.tab[7])
        guiLabelSetHorizontalAlign(GUIEditor.label[2], "right", false)
        guiLabelSetVerticalAlign(GUIEditor.label[2], "center")
        GUIEditor.edit[1] = guiCreateEdit(0.27, 0.02, 0.02, 0.02, "", true, GUIEditor.tab[7])
        killButton = guiCreateButton(0.30, 0.02, 0.03, 0.02, "Kill", true, GUIEditor.tab[7])
        giveGoldButton = guiCreateButton(0.33, 0.02, 0.03, 0.02, "Give gold", true, GUIEditor.tab[7])

        GUIEditor.tab[8] = guiCreateTab("Control", tabs)

        respawnGoldAtEdlButton = guiCreateButton(0.02, 0.02, 0.07, 0.03, "Respawn gold at edl", true, GUIEditor.tab[8])
        newRoundButton = guiCreateButton(0.09, 0.02, 0.07, 0.03, "New round", true, GUIEditor.tab[8])
        respawnAtNewLocationButton = guiCreateButton(0.02, 0.05, 0.07, 0.04, "Respawn gold at new location", true, GUIEditor.tab[8])
        newRoundButton = guiCreateButton(0.16, 0.02, 0.07, 0.03, "New round", true, GUIEditor.tab[8])


        saveAndCloseButton = guiCreateButton(1708, 23, 148, 24, "Save and Close", false, GUIEditor.window[2])    
    end
)