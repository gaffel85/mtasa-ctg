DGS = exports.dgs --shorten the export function prefix
local mapImage = nil
local lineArea = nil
local plotWindow = nil
local scrollPane = nil
local xScale = 1.043
local yScale = 1.038
local xOffset = 1520
local yOffset = -1484
local scaleSteps = 0.001
local offsetSteps = 0.1
local lineFragments = {}

function cleanResources()
    if lineaArea and isElement(lineArea) then
        destroyElement(lineArea)
    end
    for i, line in ipairs(lineFragments) do
        --DGS:dgsLineRemoveItem(lineArea, line)
    end
    lineFragments = {}
end

function getOrCreatePlotWindow()
    if not plotWindow then
        local resX, resY = guiGetScreenSize()
        plotWindow = DGS:dgsCreateWindow(0, 0, resX, resY, "", false)
        scrollPane = DGS:dgsCreateScrollPane(0, 0, resX, resY - 200, false, plotWindow)
        --one plus and one minus button to change scale
        local xScaleLabel = DGS:dgsCreateLabel(0.90, 0.01, 0.1, 0.02, "X Scale", true, plotWindow)
        local xScalePlusButton = DGS:dgsCreateButton(0.95, 0.01, 0.04, 0.02, "+", true, plotWindow)
        local xScaleMinusButton = DGS:dgsCreateButton(0.97, 0.01, 0.04, 0.02, "-", true, plotWindow)
        local yScaleLabel = DGS:dgsCreateLabel(0.90, 0.03, 0.1, 0.02, "Y Scale", true, plotWindow)
        local yScalePlusButton = DGS:dgsCreateButton(0.95, 0.03, 0.04, 0.02, "+", true, plotWindow)
        local yScaleMinusButton = DGS:dgsCreateButton(0.97, 0.03, 0.04, 0.02, "-", true, plotWindow)
        local xOffsetLabel = DGS:dgsCreateLabel(0.90, 0.05, 0.1, 0.02, "X Offset", true, plotWindow)
        local xOffsetPlusButton = DGS:dgsCreateButton(0.95, 0.05, 0.04, 0.02, "+", true, plotWindow)
        local xOffsetMinusButton = DGS:dgsCreateButton(0.97, 0.05, 0.04, 0.02, "-", true, plotWindow)
        local yOffsetLabel = DGS:dgsCreateLabel(0.90, 0.07, 0.1, 0.02, "Y Offset", true, plotWindow)
        local yOffsetPlusButton = DGS:dgsCreateButton(0.95, 0.07, 0.04, 0.02, "+", true, plotWindow)
        local yOffsetMinusButton = DGS:dgsCreateButton(0.97, 0.07, 0.04, 0.02, "-", true, plotWindow)
        local reduceLocationsButton = DGS:dgsCreateButton(0.90, 0.09, 0.1, 0.02, "Reduce Locations", true, plotWindow)
        addEventHandler ( "onDgsMouseClick", xScalePlusButton, function() 
            xScale = xScale + scaleSteps
            outputConsole("X Scale: "..xScale)
            plotLocations()
        end)
        addEventHandler ( "onDgsMouseClick", xScaleMinusButton, function() 
            xScale = xScale - scaleSteps
            outputConsole("X Scale: "..xScale)
            plotLocations()
        end)
        addEventHandler ( "onDgsMouseClick", yScalePlusButton, function() 
            yScale = yScale + scaleSteps
            outputConsole("Y Scale: "..yScale)
            plotLocations()
        end)
        addEventHandler ( "onDgsMouseClick", yScaleMinusButton, function() 
            yScale = yScale - scaleSteps
            outputConsole("Y Scale: "..yScale)
            plotLocations()
        end)
        addEventHandler ( "onDgsMouseClick", xOffsetPlusButton, function() 
            xOffset = xOffset + offsetSteps
            outputConsole("X Offset: "..xOffset)
            plotLocations()
        end)
        addEventHandler ( "onDgsMouseClick", xOffsetMinusButton, function() 
            xOffset = xOffset - offsetSteps
            outputConsole("X Offset: "..xOffset)
            plotLocations()
        end)
        addEventHandler ( "onDgsMouseClick", yOffsetPlusButton, function() 
            yOffset = yOffset + offsetSteps
            outputConsole("Y Offset: "..yOffset)
            plotLocations()
        end)
        addEventHandler ( "onDgsMouseClick", yOffsetMinusButton, function() 
            yOffset = yOffset - offsetSteps
            outputConsole("Y Offset: "..yOffset)
            plotLocations()
        end)
        addEventHandler ( "onDgsMouseClick", reduceLocationsButton, function() 
            outputChatBox("Reducing locations")
            callReducer()
        end)
    end
    return plotWindow
end

function callReducer()
    outputChatBox("callReducer")
    MeanPosReducer.markStrongLocationsSomeAndWait(plotLocations)
end

function drawMap()
    outputChatBox("Drawing map")
    if mapImage then
        return
    end

    getOrCreatePlotWindow()
    local mapPath = "img/san-fierro-h.png"
    mapImage = DGS:dgsCreateImage(0, 0, 2237, 1498, mapPath, false, scrollPane)
    if not mapImage then
        outputChatBox("Failed to create map image")
        return
    end
end

function getMapX(x)
    return (xOffset -x) * xScale
end

function getMapY(y)
    return (yOffset -y) * yScale
end

local dotWidth = 2
function plotLocations()
    cleanResources()
    getOrCreatePlotWindow()
    lineArea = DGS:dgsCreateLine(0, 0, 2237, 1498, false, scrollPane)
    DGS:dgsSetLayer(lineArea, "top")
    local allLocations = getAllLocations()
    outputChatBox("Plotting "..#allLocations.." locations")
    local index = 0
    for i, location in ipairs(allLocations) do
        local x1, y1 = getMapX(location.y), getMapY(location.x)
        local x2 = x1 + dotWidth
        local y2 = y1 + dotWidth
        local strongness = location.stongness or 255
        local color = tocolor(math.min(255, location.neighbors * 255 / 100), 255 - location.neighbors * 255 / 100, 0, 255)
        if location.weak then
            color = tocolor(0, 0, 255, 255)
        end
        local lineIndex = DGS:dgsLineAddItem(lineArea, x1, y1, x2, y2, dotWidth, color, false)
        table.insert(lineFragments, lineIndex)
        index = index + 1
        if index == 1 then
            outputChatBox("Dot: strongness: "..strongness..", neighbors: "..location.neighbors)
            --break loop
        end
        
    end
end

function togglePlotterWindow()
    getOrCreatePlotWindow()
    if DGS:dgsGetVisible(plotWindow) then
        DGS:dgsSetVisible(plotWindow, false)
        guiSetInputEnabled(false)
        showCursor(false)
    else
        DGS:dgsSetVisible(plotWindow, true)
        guiSetInputEnabled(true)
        showCursor(true)
        drawMap()
        plotLocations()
    end
end

clearLocations()
readLocationsFromJsonFile()
--outputConsole(" ============ Read "..#getAllLocations().." locations")
--drawMap()
--plotLocations()

addEventHandler("onClientResourceStart", resourceRoot, function()
    --drawMap()
    --plotLocations()

    bindPlotterKeys(source)
    togglePlotterWindow()
end)


function bindPlotterKeys(player)
    -- outputChatBox("bindPlotterKeys")
      bindKey ( "F7", "up", togglePlotterWindow )
  end
  
  function unbindPlotterKeys(player)
      unbindKey ( "F7" )
  end
  
  function onJoinForPlotterKeys ( )
      bindPlotterKeys(source)
  end
  addEventHandler("onPlayerJoin", getRootElement(), onJoinForPlotterKeys)
  
    --unbind on quit
  function onQuitForPlotterKeys ( )
      unbindPlotterKeys(source)
  end
  addEventHandler("onPlayerQuit", getRootElement(), onQuitForPlotterKeys)