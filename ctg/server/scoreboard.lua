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
            return getPlayerScore(a) > getPlayerScore(b)
        end)
        for _, player in ipairs(players) do
            local score = getPlayerScore(player) or 0
            scoreBoardString = scoreBoardString .. getPlayerName(player) .. ": " .. score .. "\n"
        end
        getOrCreateScoreBoardDisplay()
        textItemSetText(scoreText, scoreBoardString)
    end, 1000, 0)
end)

addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), function()
    if scoreBoardDisplay then
        textDestroyDisplay(scoreBoardDisplay)
    end
    if timer then
        killTimer(timer)
    end
end)
