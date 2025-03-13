addEventHandler("onPlayerJoin", getRootElement(), function()
    -- create small window to he left with for labels, one on each row.
    local helpWindow = guiCreateWindow(0.01, 0.7, 0.1, 0.1, "Help", true)
    local helpLabel = guiCreateLabel(0.01, 0.1, 0.98, 0.9, "F1 = Join team 1\nF2 = Join team 2\nF3 = Choose power ups\nF4 = Vote for next vehicle", true, helpWindow)
    guiLabelSetHorizontalAlign(helpLabel, "center", true)
    guiLabelSetVerticalAlign(helpLabel, "center")
    guiSetVisible(helpWindow, false)   
end)