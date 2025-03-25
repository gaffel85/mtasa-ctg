local checkScoresTimer

function scorePercentageForPlayers(players)
    if #players == 0 then return {} end

    -- Find the best score
    local bestScore = 0
    for _, player in players do
        local score = getPlayerScore(player) or 0
        if score > bestScore then
            bestScore = score
        end
    end

    -- Notify players below 70% of the best score
    local playesWithScore = {}
    for _, player in ipairs(players) do
        local score = getPlayerScore(player) or 0
        local percentage = score / bestScore
        table.insert(playesWithScore, {player = player, score = score, percentage = percentage})
    end
end

-- Function to compare scores and notify players
local function compareScores()
    for _, player in ipairs(getElementsByType("player")) do
        if isFarEnoughFromLeader(player) then
            notfiyToUseCatchupPower(player)
        else 
            stopNotifyingCatchupPower(player)
        end
    end
end

function stopNotifyingCatchupPower(player)
    if catchUpPowerDisplay then
        textDisplayRemoveObserver ( catchUpPowerDisplay, player )
    end
end

function notfiyToUseCatchupPower(player)
    if not catchUpPowerDisplay then
        createMessageDisplay()
    end
    textDisplayAddObserver ( catchUpPowerDisplay, player )
end

local catchUpPowerDisplay = nil
function createMessageDisplay()
    catchUpPowerDisplay = textCreateDisplay ()
    local howToEnableItem = textCreateTextItem ( "Press Z to catch up", 0.5, 0.07, "medium", 255, 255, 255, 255, 3, "center", "top", 200) 
    local messageItem = textCreateTextItem ( "You are far away from other players, that's ntot fun!", 0.5, 0.74, "medium", 200, 200, 255, 255, 1.5, "center", "top", 200) 
    textDisplayAddText ( catchUpPowerDisplay, messageItem )
    textDisplayAddText ( catchUpPowerDisplay, howToEnableItem )
end

function useCatchUp(player)
    if isFarEnoughFromLeader(player) then
        local playersWithScore = scorePercentageForPlayers(getElementsByType("player"))
        if #playersWithScore == 0 then
            return
        end
        local myPercentage = 1
        for _, player in ipairs(playersWithScore) do
            if player.player == player then
                myPercentage = player.percentage
                break
            end
        end
        if myPercentage < 0.7 then
            askForTeleport(player, 1)
        elseif myPercentage < 0.8 then
            askForTeleport(player, 3)
        elseif myPercentage < 0.9 then
            askForTeleport(player, 7)
        else
            spawnCloseToMeanPositionOfAllPlayers(player)
        end
    end
end

-- Start the timer when the resource starts
addEventHandler("onResourceStart", resourceRoot, function()
    checkScoresTimer = setTimer(compareScores, 5000, 0) -- 5 seconds
end)

-- Stop the timer when the resource stops
addEventHandler("onResourceStop", resourceRoot, function()
    if isTimer(checkScoresTimer) then
        killTimer(checkScoresTimer)
    end
end)

-- Helper function to get a player's score (replace with your actual scoring logic)
function getPlayerScore(player)
    return getElementData(player, "score") -- Assuming scores are stored as element data
end

registerBindFunctions(function(player)
    bindKey(player, "z", "up", useCatchUp)
end, function(player)
    unbindKey(player, "z", "up", useCatchUp)
end)