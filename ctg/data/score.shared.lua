local SCORE_KEY = "Score"
local SCORE_PERCENTAGE_KEY = "ScorePercentage"
local TOTAL_SCORE_KEY = "TotalScore"

function getScoreDataKey()
    return SCORE_KEY
end

function getScorePercentageDataKey()
    return SCORE_PERCENTAGE_KEY
end

function givePointsToPlayer(player, points)
    local score = getElementData(player, SCORE_KEY)
    if (score == false) then
        score = 0
    end
    local newScore = score + points

    local totalScore = changeTotalScore(points)
    setScorePercentage(player, newScore, totalScore)
    setElementData(player, SCORE_KEY, newScore)
end

function changeTotalScore(change)
    local totalScore = getElementData(resourceRoot, TOTAL_SCORE_KEY)
    if (totalScore == false) then
        totalScore = 0
    end
    totalScore = totalScore + change
    setElementData(resourceRoot, TOTAL_SCORE_KEY, totalScore)
    return totalScore
end

function setScorePercentage(player, newScore, totalScore)
    local avgScore = totalScore / #(getElementsByType("player"))
    if avgScore == 0 then
        avgScore = 1
    end
    local percentage = newScore / avgScore
    setElementData(player, SCORE_PERCENTAGE_KEY, percentage)
end


function setScoreDeug(player, score)
    setElementData(player, SCORE_KEY, score)
end

function getPlayerScore(player)
    return getElementData(player, SCORE_KEY)
end

function resetScore()
    local players = getElementsByType("player")
    for k, v in ipairs(players) do
        setElementData(v, SCORE_KEY, 0)
    end
    setElementData(resourceRoot, TOTAL_SCORE_KEY, 0)
end

addEventHandler("onPlayerQuit", root,
    function()
        local score = getPlayerScore(source)
        if (score == false) then
            score = 0
        end
        local totalScore = changeTotalScore(-score)
        for k, player in ipairs(getElementsByType("player")) do
            setScorePercentage(player, getPlayerScore(player), totalScore)
        end

        setElementData(source, SCORE_KEY, false)
    end
)

addEventHandler("onPlayerJoin", root,
    function()
        setElementData(source, SCORE_KEY, 0)
    end
)