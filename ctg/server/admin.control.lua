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
            outputChatBox("Admin set score for " .. playerNick .. " to " .. score, client, 0, 255, 0)
        end
    end
)

addEvent("adminSpawnGoldAt10sAgo", true)
addEventHandler("adminSpawnGoldAt10sAgo", getRootElement(),
    function()
        local carrier = getGoldCarrier()
        if carrier then
            triggerClientEvent(carrier, "reportLastTransformTimeAgo", resourceRoot, 10000, "replaceGold")
            outputChatBox("Requesting historical location from carrier " .. getPlayerName(carrier), client, 0, 255, 0)
        else
            outputChatBox("No current gold carrier to track history from.", client, 255, 0, 0)
        end
    end
)

addEvent("adminRespawnGoldClosest", true)
addEventHandler("adminRespawnGoldClosest", getRootElement(),
    function()
        if respawnGoldCloseToCurrent() then
            outputChatBox("Gold respawned at closest spawn point.", client, 0, 255, 0)
        else
            outputChatBox("Failed to find closest spawn point.", client, 255, 0, 0)
        end
    end
)

addEvent("adminRespawnGoldLast", true)
addEventHandler("adminRespawnGoldLast", getRootElement(),
    function()
        if respawnGoldAtLastSpawn() then
            outputChatBox("Gold respawned at its last spawn point.", client, 0, 255, 0)
        else
            outputChatBox("No last spawn point recorded.", client, 255, 0, 0)
        end
    end
)

addEvent("adminRespawnGoldRandomNearby", true)
addEventHandler("adminRespawnGoldRandomNearby", getRootElement(),
    function()
        if respawnGoldRandomNearby() then
            outputChatBox("Gold respawned at a random nearby location (100m).", client, 0, 255, 0)
        else
            outputChatBox("Failed to find any nearby locations.", client, 255, 0, 0)
        end
    end
)

addEvent("adminFixPlayer", true)
addEventHandler("adminFixPlayer", getRootElement(),
    function(playerName)
        local targetPlayer = getPlayerFromName(playerName)
        if not targetPlayer then return end

        outputServerLog("Admin " .. getPlayerName(client) .. " fixing player " .. playerName)
        
        -- Call shared fix logic from ctg.server.main.lua
        if type(fixPlayer) == "function" then
            fixPlayer(targetPlayer)
        end

        outputChatBox("Admin fixed player " .. playerName, client, 0, 255, 0)
        outputChatBox("An admin fixed and respawned you.", targetPlayer, 0, 255, 0)
    end
)

function fixPlayer(targetPlayer)
    if not isElement(targetPlayer) then return end

    local pname = tostring(getPlayerName(targetPlayer) or "unknown")
    outputServerLog("Fixing player " .. pname)

    -- Drop gold if carrier
    local currentCarrier = getGoldCarrier()
    if targetPlayer == currentCarrier then
        outputServerLog("[FIX] Player " .. pname .. " is carrier, dropping gold.")
        local px, py, pz = getElementPosition(targetPlayer)
        clearGoldCarrier()
        spawnGoldAtTransform(px, py, pz)
        refreshAllBlips()
    end

    -- destroy any occupied vehicle first to avoid orphan vehicles
    local veh = getPedOccupiedVehicle(targetPlayer)
    if veh then
        outputServerLog("Destroying vehicle for " .. pname)
        destroyElement(veh)
    end

    -- Spawn like a new player (uses current vehicle model from map)
    spawn(targetPlayer, false)

    -- Give the spawn logic time to create/warp into the vehicle, then trigger catch-up
    setTimer(function(p)
        if isElement(p) and type(useCatchUpForce) == "function" then
            useCatchUpForce(p)
        end
    end, 1000, 1, targetPlayer)
end

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

addEvent("adminTeleportPlayerToPlayer", true)
addEventHandler("adminTeleportPlayerToPlayer", getRootElement(),
    function(targetName, destName)
        local target = getPlayerFromName(targetName)
        local dest = getPlayerFromName(destName)
        
        if target and dest then
            outputServerLog("Admin " .. getPlayerName(client) .. " teleporting " .. targetName .. " to " .. destName)
            triggerClientEvent(target, "startSuperCatchupSequence", resourceRoot, dest)
            outputChatBox("Teleporting " .. targetName .. " to " .. destName .. "...", client, 0, 255, 0)
        else
            outputChatBox("Failed to find one of the players.", client, 255, 0, 0)
        end
    end
)

addEvent("saveGameState", true)
addEvent("loadGameState", true)

addEventHandler("saveGameState", getRootElement(),
    function()
        local data = {}
        data.players = {}
        for _, player in ipairs(getElementsByType("player")) do
            local name = getPlayerName(player)
            local score = getElementData(player, "Score") or 0
            data.players[name] = {
                score = score
            }
        end

        local teams = getTeams()
        data.teams = {}
        for i, team in ipairs(teams) do
            data.teams[i] = {
                score = team.score,
                members = team.members
            }
        end

        data.totalScore = getElementData(resourceRoot, "TotalScore") or 0

        local json = toJSON(data)
        local file = fileCreate("gamestate.json")
        if file then
            fileWrite(file, json)
            fileClose(file)
            outputChatBox("Game state saved to gamestate.json", client, 0, 255, 0)
        else
            outputChatBox("Failed to save game state", client, 255, 0, 0)
        end
    end
)

addEventHandler("loadGameState", getRootElement(),
    function()
        if not fileExists("gamestate.json") then
            outputChatBox("No saved game state found", client, 255, 0, 0)
            return
        end

        local file = fileOpen("gamestate.json")
        if not file then
            outputChatBox("Failed to open gamestate.json", client, 255, 0, 0)
            return
        end

        local json = fileRead(file, fileGetSize(file))
        fileClose(file)

        local data = fromJSON(json)
        if not data then
            outputChatBox("Failed to parse gamestate.json", client, 255, 0, 0)
            return
        end

        -- Restore player scores and teams
        local teams = getTeams()
        
        -- Clear existing team members first
        for _, team in ipairs(teams) do
            clearTeamMembers(team)
        end

        for _, player in ipairs(getElementsByType("player")) do
            local name = getPlayerName(player)
            if data.players[name] then
                setElementData(player, "Score", data.players[name].score)
            end

            -- Restore team assignment
            for i, teamData in ipairs(data.teams) do
                for _, memberName in ipairs(teamData.members) do
                    if memberName == name then
                        switchToTeam(teams[i], player, false)
                    end
                end
            end
        end

        -- Restore team scores
        for i, teamData in ipairs(data.teams) do
            if teams[i] then
                setTeamScore(teams[i], teamData.score)
            end
        end

        -- Restore total score
        setElementData(resourceRoot, "TotalScore", data.totalScore)

        outputChatBox("Game state loaded from gamestate.json", client, 0, 255, 0)
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