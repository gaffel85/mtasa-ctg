local SCORE_BOARD_TEXT_ID = "SCORE_BOARD_TEXT_ID"
local scoreBoardDisplay = nil
local scoreText = nil
local timer = nil

function createScoreBoardDisplay()
    scoreBoardDisplay = textCreateDisplay ()
    scoreText = textCreateTextItem ( "Score", 0.70, 0.02, "medium", 255, 255, 255, 255, 1, "left", "top", 128) 
    textDisplayAddText ( scoreBoardDisplay, scoreText )
    return scoreBoardDisplay
end

function getOrCreateScoreBoardDisplay()
    if not scoreBoardDisplay then
        scoreBoardDisplay = createScoreBoardDisplay()
    end
    return scoreBoardDisplay
end

--[[
-- remove all these IDs

]]--
function removeLampposts()
    removeWorldModel(642, 10000, 0, 0, 0)
    removeWorldModel(1211, 10000, 0, 0, 0)
    removeWorldModel(1223, 10000, 0, 0, 0)
    removeWorldModel(1226, 10000, 0, 0, 0)
    removeWorldModel(1231, 10000, 0, 0, 0)
    removeWorldModel(1232, 10000, 0, 0, 0)
    removeWorldModel(1238, 10000, 0, 0, 0)
    removeWorldModel(1244, 10000, 0, 0, 0)
    removeWorldModel(1257, 10000, 0, 0, 0)
    removeWorldModel(1270, 10000, 0, 0, 0)
    removeWorldModel(1283, 10000, 0, 0, 0)
    removeWorldModel(1284, 10000, 0, 0, 0)
    removeWorldModel(1285, 10000, 0, 0, 0)
    removeWorldModel(1286, 10000, 0, 0, 0)
    removeWorldModel(1287, 10000, 0, 0, 0)
    removeWorldModel(1288, 10000, 0, 0, 0)
    removeWorldModel(1289, 10000, 0, 0, 0)
    removeWorldModel(1290, 10000, 0, 0, 0)
    removeWorldModel(1291, 10000, 0, 0, 0)
    removeWorldModel(1293, 10000, 0, 0, 0)
    removeWorldModel(1294, 10000, 0, 0, 0)
    removeWorldModel(1297, 10000, 0, 0, 0)
    removeWorldModel(1315, 10000, 0, 0, 0)
    removeWorldModel(1350, 10000, 0, 0, 0)
    removeWorldModel(1351, 10000, 0, 0, 0)
    removeWorldModel(1352, 10000, 0, 0, 0)
    removeWorldModel(1375, 10000, 0, 0, 0)
    removeWorldModel(1478, 10000, 0, 0, 0)
    removeWorldModel(1568, 10000, 0, 0, 0)
    removeWorldModel(3091, 10000, 0, 0, 0)
    removeWorldModel(3460, 10000, 0, 0, 0)
    removeWorldModel(3516, 10000, 0, 0, 0)
    removeWorldModel(3853, 10000, 0, 0, 0)
    removeWorldModel(3855, 10000, 0, 0, 0)
end

--on player join and quit add player as observer
addEventHandler("onPlayerJoin", getRootElement(), function()
    textDisplayAddObserver(getOrCreateScoreBoardDisplay(), source)
end)
addEventHandler("onPlayerQuit", getRootElement(), function()
    textDisplayRemoveObserver(getOrCreateScoreBoardDisplay(), source)
end)

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), function()
    -- add all players as observers
    for _, player in ipairs(getElementsByType("player")) do
        textDisplayAddObserver(getOrCreateScoreBoardDisplay(), player)
    end
    timer = setTimer(function()
        local scoreBoardString = "Score Board:\n"
        --append scores for all players sorted by score
        local players = getElementsByType("player")
        table.sort(players, function(a, b)
            return (getPlayerScore(a) or 0) > (getPlayerScore(b) or 0)
        end)
        for _, player in ipairs(players) do
            local score = getPlayerScore(player) or 0
            scoreBoardString = scoreBoardString .. getPlayerName(player) .. ": " .. score .. "\n"
        end
        getOrCreateScoreBoardDisplay()
        textItemSetText(scoreText, scoreBoardString)
    end, 1000, 0)

    removeLampposts()
end)

addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), function()
    if scoreBoardDisplay then
        textDestroyDisplay(scoreBoardDisplay)
    end
    if timer then
        killTimer(timer)
    end
end)
