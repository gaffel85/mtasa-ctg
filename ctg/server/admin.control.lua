-- client events and funtions for setting money, score and rank
addEvent("fromClientSetPlayerMoney", true)
addEvent("fromClientSetPlayerScore", true)
addEvent("fromClientSetPlayerRank", true)
addEvent("savePropsFromServer", true)

-- handler for money. first parameter is the player nick, second is the money
addEventHandler("fromClientSetPlayerMoney", getRootElement(),
    function(playerNick, money)
        local player = getPlayerFromName(playerNick)
        if player then
            setPlayerMoney(player, money)
        end
    end
)

-- handler for score. first parameter is the player nick, second is the score
addEventHandler("fromClientSetPlayerScore", getRootElement(),
    function(playerNick, score)
        local player = getPlayerFromName(playerNick)
        if player then
            setPlayerScore(player, score)
        end
    end
)

-- handler for rank. first parameter is the player nick, second is the rank
addEventHandler("fromClientSetPlayerRank", getRootElement(),
    function(playerNick, rank)
        local player = getPlayerFromName(playerNick)
        if player then
            setUsedRang(player, rank)
            setCompleteRank(player, rank)
        end
    end
)

addEventHandler("savePropsFromServer", getRootElement(),
    function(props)
        setElementData(resourceRoot, "props", props)

        -- Logging for backup/debugging
        local timestamp = getRealTime().timestamp
        local filename = "props_backup_"..timestamp..".txt"
        local file = fileCreate(filename)
        if file then
            fileWrite(file, inspect(props))
            fileClose(file)
        end
    end
)