local spawnPoints
local currentSpawn = 1
local participants = {}
local blowingPlayer = nil

--addEvent("goldDelivered")
--addEvent("goldCarrierChanged")

scoreboardRes = getResourceFromName("scoreboard")

function goldPickedUp(player)
    --outputServerLog("Gold picked up by "..inspect(player))
    changeGoldCarrier(player)
    if getGoldCarrier() then
        showPresentGoldCarrier(getGoldCarrier())
    else
        outputServerLog("No gold carrier found")
    end
    
    spawnNewHideout()
end

function getSpawnPoints()
    return spawnPoints
end

-- Stop player from exiting vehicle
function exitVehicle(thePlayer, seat, jacked)
    cancelEvent()
end
addEventHandler("onVehicleStartExit", getRootElement(), exitVehicle)

function filterOutLocationsWithFewestNeighbors(locations)
    local minNeighbors = 0
    for i, location in ipairs(locations) do
        if (location.neighbors or 0) < minNeighbors or minNeighbors == 0 then
            minNeighbors = location.neighbors or 0
        end
    end

    local filteredLocations = {}
    for i, location in ipairs(locations) do
        if (location.neighbors or 0) == minNeighbors then
            table.insert(filteredLocations, location)
        end
    end

    return filteredLocations
end

function spawn(thePlayer, random)
    local all = getAllLocations()
    if #all > 0 then
        local withFewestNeighbors = all --filterOutLocationsWithFewestNeighbors(all)
        local randomLocation = withFewestNeighbors[math.random(#withFewestNeighbors)]
        --outputServerLog("Spawning at random location "..inspect(randomLocation).." with "..inspect(randomLocation.neighbors).." neighbors")
        spawnAt(thePlayer, randomLocation.x, randomLocation.y, randomLocation.z, randomLocation.rx, randomLocation.ry, randomLocation.rz)
        return
    else
        local spawnPoint = spawnPoints[math.random(#spawnPoints)]
        if (random == true) then
            local spawnPoint = spawnPoints[currentSpawn]
            currentSpawn = currentSpawn % #spawnPoints + 1
        end  
        spawnAtSpawnpointEdl(thePlayer, spawnPoint)
    end
end

function spawnAtSpawnpointEdl(thePlayer, spawnPointEdl)
    local posX, posY, posZ = coordsFromEdl(spawnPointEdl)
    local rotX, rotY, rotZ = rotFromEdl(spawnPointEdl)
    --outputServerLog("Spawning at spawn point edl "..inspect(spawnPointEdl).." with "..inspect(posX)..", "..inspect(posY)..", "..inspect(posZ)..", "..inspect(rotX)..", "..inspect(rotY)..", "..inspect(rotZ))
    spawnAtSpawnpoint(thePlayer, posX, posY, posZ, rotX, rotY, rotZ)
end

function spawnAtSpawnpoint(thePlayer, posX, posY, posZ, rotX, rotY, rotZ)
    local allLocations = getAllLocations()
    if #allLocations == 0 then
        spawnAt(thePlayer, posX, posY, posZ, rotX, rotY, rotZ)
        return
    end

    local radius = 20
    local locations = {}
    while #locations == 0 do
        --outputServerLog("Getting locations with radius from spawnAtSpawnpoint"..inspect(posX)..", "..inspect(posY)..", "..inspect(posZ)..", "..radius)
        locations = getLocations(posX, posY, posZ, radius)
        radius = radius + 10
    end

    local posX, posY, posZ, rotX, rotY, rotZ = getRandomRotatedLocationOrOther(locations, 1)

    if posX == 0 then
        posX, posY, posZ = coordsFromEdl(spawnPoint)
        rotX, rotY, rotZ = rotFromEdl(spawnPoint)
    end
    spawnAt(thePlayer, posX, posY, posZ, rotX, rotY, rotZ)
end

function spawnAt(player, posX, posY, posZ, rotX, rotY, rotZ)
    --outputServerLog("Spawning at "..inspect(posX)..", "..inspect(posY)..", "..inspect(posZ)..", "..inspect(rotX)..", "..inspect(rotY)..", "..inspect(rotZ))
    -- posX="" posY="" posZ=""
    local vehicle = createVehicle(getCurrentVehicle(), posX, posY, posZ + 2, rotX, rotY, rotZ, "Hunter")
    spawnPlayer(player, 0, 0, 0, 0, 285)
    setTimer(function()
        warpPedIntoVehicle(player, vehicle)
        fadeCamera(player, true)
        setCameraTarget(player, player)
        makePlayerGhost(player, 2, true, false)
    end, 50, 1)
end

function respawnAllPlayers()
    local players = getElementsByType("player")
    for k, v in ipairs(players) do
        spawn(v, true)
    end
end

function repairAllCars()
    local players = getAlivePlayers()
    for k, v in ipairs(players) do
        local veh = getPedOccupiedVehicle(v)
        if (veh and veh ~= false ) then
            fixVehicle(veh)
        end
    end
end

function arrayExists(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function getIndex(tab, val)
    local index = nil
    for i, v in ipairs (tab) do 
        if (v == val) then
          index = i 
        end
    end
    return index
end

function shuffle(tbl)
    for i = #tbl, 1, -1 do
        local rand = math.random(i)
        tbl[i], tbl[rand] = tbl[rand], tbl[i]
    end
end

function removeFromTable(tab, val)
    local idx = getIndex(tab, val)
    if idx then 
        table.remove(tab, idx)
        return true
    end
    return false
end

function contains(tab, val)
    local idx = getIndex(tab, val)
    if idx then 
        return true
    end
    return false
end

function destroyElementsByType(elementType)
    local elements = getElementsByType(elementType)
    for i, v in ipairs(elements) do
        destroyElement(v)
    end
end

function parseMapArea(mapRoot)
    local mapAreaElements = getElementsByType("maparea", mapRoot)
    if mapAreaElements == nil or #mapAreaElements == 0 then
        outputServerLog("No map area elements found")
        mapArea = { xMin = -3500, xMax = 3500, yMin = -3500, yMax = 3500 }
        return
    end
    local mapAreaEdl = mapAreaElements[1]
    local xMin = tonumber(getElementData(mapAreaEdl, "xMin"))
    local xMax = tonumber(getElementData(mapAreaEdl, "xMax"))
    local yMin = tonumber(getElementData(mapAreaEdl, "yMin"))
    local yMax = tonumber(getElementData(mapAreaEdl, "yMax"))
    setMapArea({ xMin = xMin, xMax = xMax, yMin = yMin, yMax = yMax })
end

function testGather()
    local spawn = spawnPoints[1]
    local x, y, z = coordsFromEdl(spawn)
    outputServerLog("Spawn location "..inspect(spawn).." "..inspect(x).." "..inspect(y).." "..inspect(z))
    gatherPlayersAt(x, y, z, 10, 2)
end

function respawnAfterMapFinished()
    outputServerLog("Respawning all players after map finished")
    respawnAllPlayers()
end

function startGameMap(startedMap)
    local mapRoot = getResourceRootElement(startedMap)
    outputServerLog("Starging map "..inspect(getElementID(mapRoot)))
    spawnPoints = getElementsByType("playerSpawnPoint", mapRoot)
    goldSpawnPoints = getElementsByType("goldSpawnPoint", mapRoot)
    hideouts = getElementsByType("hideout", mapRoot)
    parseMapArea(mapRoot)
    currentSpawn = math.random(#spawnPoints)
    mapChanged(respawnAfterMapFinished)
    setGoldSpawns(goldSpawnPoints)
    setHideouts(hideouts)
    resetGame()
end
addEventHandler("onGamemodeMapStart", getRootElement(), startGameMap)

local hasPlotted = false
addEvent("plotPointsFromClient", true)
addEventHandler("plotPointsFromClient", resourceRoot, function()
    if hasPlotted then
        refreshAllBlips()
        hasPlotted = false
        return
    end

    for k, goldSpawn in ipairs(goldSpawnPoints) do
        local posX, posY, posZ = coordsFromEdl(goldSpawn)
        createBlip(posX, posY, posZ, 0, 2, 0, 255, 255, 255, 0)
    end
    for k, hideout in ipairs(hideouts) do
        local posX, posY, posZ = coordsFromEdl(hideout)
        createBlip(posX, posY, posZ, 0, 2, 0, 0, 255, 255, 0)
    end
    hasPlotted = true
end)

function joinHandler()
    spawn(source, false)
    startGameIfEnoughPlayers()
  -- outputChatBox("Welcome to Capture the Gold!", source)
    refreshAllBlips()
    setPlayerMoney(source, 10000)
    --plotPoints()
end
addEventHandler("onPlayerJoin", getRootElement(), joinHandler)

function startGameIfEnoughPlayers()
    local players = getElementsByType("player")
	if #players < 3 then
        --resetGame()
    end
end

function goldDelivered(player)
    local oldHideout = getTeamHideout(player).edl
    removeOldHideout()
	givePointsToPlayer(getGoldCarrier(), 500)
    giveTeamScore(player, 500)
    -- triggerEvent("goldDelivered", root, getGoldCarrier(), 500)
	showTextGoldDelivered(getGoldCarrier())

    local newGoldEdl = prepareNextGold()
    outputServerLog("1 "..inspect(oldHideout))
    activeRoundFinished(oldHideout, newGoldEdl)
end

function forceNextRound()
    removeOldHideout()
    resetRoundVars()
    scheduleNextGold(1)
end
addEvent("forceNextRoundFromClient", true)
addEventHandler("forceNextRoundFromClient", resourceRoot, forceNextRound)

function activeRoundFinished(oldHideout, newGoldEdl)
    nextVehicle()
    resetRoundVars()

    local x, y, z = coordsFromEdl(oldHideout)
    outputServerLog("1 "..inspect(oldHideout).." "..inspect(x).." "..inspect(y).." "..inspect(z))
    local gatherTime = math.min(getConst().goldSpawnTime, getConst().gatherTime)
    gatherPlayersAt(x, y, z, 70, gatherTime)

    scheduleNextGold(getConst().goldSpawnTime)
end

function resetRoundVars()
    resetPowerStatesOnDeliverdResourceBased()
    clearGoldCarrier()
end

function resetGame()
    removeOldHideout()
    removeOldGold()
    resetScore()
    resetTeamScore()
    resetPlayerMoney()
    repairAllCars()
    respawnAllPlayers()
	repairAllCars()
    resetRoundVars()
	scheduleNextGold(2)
end

function playerDied(player)
    outputChatBox("playerDied")
    local posX, posY, posZ = getElementPosition(player)
    if player == getGoldCarrier() then
        clearGoldCarrier()
      -- outputChatBox("had position"..inspect(posX))
        spawnGoldAtTransform(posX, posY, posZ)
        refreshAllBlips()
    end
    local closestSpawn = positionCloseTo(spawnPoints, {x = posX, y = posY, z = posZ}, 0)
    spawnAtSpawnpointEdl(player, closestSpawn)
end

function playerWastedMain(ammo, attacker, weapon, bodypart)
    outputChatBox("playerWastedMain")
    cleanStuffInWorld()
    playerDied(source)
    --local posX, posY, posZ = getElementPosition(source)
    --spawnAt(source, posX, posY, posZ, 0, 0, 0)

    --showRepairingCar(source)
    --toggleAllControls(source, false, true, false)
    --onRepairCar(source)
    --local theWasted = source
    --setTimer(function()
    --    toggleAllControls(theWasted, true, true, true)
    --end, 5000, 1)
end
addEventHandler("onPlayerWasted", getRootElement(), playerWastedMain)

-- listen for event from client called "reportTransform"
--addEvent("reportLastTransform", true)
addEvent("reportTransform", true)
addEventHandler("reportTransform", resourceRoot, function(transform, param1, param2, param3, param4)
    outputChatBox("reportTransform in main "..inspect(transform)..' '..inspect(param1)..' '..inspect(param2)..' '..inspect(param3))
    if param1 and param1 == "replaceGold" then
        spawnGoldAtTransform(transform.x, transform.y, transform.z)
        refreshAllBlips()
    elseif param1 and param1 == "teleportTo" then
        outputChatBox(inspect(param2))
        teleportTo(param2, transform)
    elseif param1 and param1 == "teleportOr" then
        if not param2 or not param3 or not param4 then
            outputServerLog("Missing params in teleportOr: ["..inspect(param2)..", "..inspect(param3)..", "..inspect(param4).."]")
            return
        end
        --outputServerLog("Teleporting to or: ["..inspect(transform)..", "..inspect(param2)..", "..inspect(param3)..", "..inspect(param4).."]")
        teleportToOr(param2, transform, param3, param4)
    else
        outputConsole("Unknown param1 in reportTransform: ["..param1.."]")
    end
end)

function startSpectating(player)
    triggerClientEvent("startSpectating", player)
end

function coordsFromEdl(element)
    if element then 
        local posX = getElementData(element, "posX")
        local posY = getElementData(element, "posY")
        local posZ = getElementData(element, "posZ")
        return posX or 0, posY or 0, posZ or 0
    end
    return 0, 0, 0
end

function rotFromEdl(element)
    local posX = getElementData(element, "rotX")
    local posY = getElementData(element, "rotY")
    local posZ = getElementData(element, "rotZ")
    return posX or 0, posY or 0, posZ or 0
end

function quitPlayer(quitType)
    if (source == getGoldCarrier()) then
        removeOldHideout()
        local vechilce = getPedOccupiedVehicle(source)
        if (vechilce) then
            local playerX, playerY, playerZ = getElementPosition(vechilce)
            spawnGoldAtTransform(playerX, playerY, playerZ)
            destroyElement(vechilce)
        end
        goldCarrier = nil
    end
    refreshAllBlips()
end
addEventHandler("onPlayerQuit", getRootElement(), quitPlayer)

--[[
// Added in map stuff
function commitSuicide(sourcePlayer)
    -- kill the player and make him responsible for it
    outputChatBox("killPed")
    killPed(sourcePlayer, sourcePlayer)
    --playerDied(sourcePlayer)
end
addCommandHandler("kill", commitSuicide)
]]--

addEvent("onDisplayClientText", true)
addEventHandler("onDisplayClientText", resourceRoot, displayMessageForPlayer)

addEvent("onClearClientText", true)
addEventHandler("onClearClientText", getRootElement(), clearMessageForPlayer)

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), function()
    --give money to all players 
    local players = getElementsByType("player")
    for k, v in ipairs(players) do
        setPlayerMoney(v, 10000)
    end
end)

addCommandHandler("fixit", function(thePlayer, command, newModel)
    local theVehicle = getPedOccupiedVehicle(thePlayer)
    if theVehicle then
        fixVehicle(theVehicle)
    end
end)

addCommandHandler("gather", function(thePlayer, command)
    testGather()
end)

addCommandHandler("score", function(thePlayer, command, scoreStr)
    local newScore = tonumber(scoreStr)
    if newScore then
        setScoreDeug(thePlayer, newScore)
    end
end)

addCommandHandler("param", function(source, command, paramName, paramValue)
    if (paramName == "coeff") then
        local newValue = tonumber(paramValue)
        local oldValue = getConst().goldHandlingCoeff
        getConst().goldHandlingCoeff = newValue
      -- outputChatBox("Gold handling coeff set to: "..getConst().goldHandlingCoeff.." (old was "..oldValue..")")
    end
    if (paramName == "height") then
        local newValue = tonumber(paramValue)
        local oldValue = getConst().goldHeight
        getConst().goldHeight = newValue
      -- outputChatBox("Gold height set to: "..getConst().goldHeight.." (old was "..oldValue..")")
    end
    if (paramName == "mass") then
        local newValue = tonumber(paramValue)
        local oldValue = getConst().goldMass
        getConst().goldMass = newValue
      -- outputChatBox("Gold mass set to: "..getConst().goldMass.." (old was "..oldValue..")")
    end
    if (paramName == "damage") then
        local newValue = tonumber(paramValue)
        local oldValue = getConst().damageMultiplierWeight
        getConst().damageMultiplierWeight = newValue
      -- outputChatBox("Damage multiplier set to: "..getConst().damageMultiplierWeight.." (old was "..oldValue..")")
    end
    local carrier = getGoldCarrier()
    if (carrier) then
        removeVechicleHandling(getGoldCarrier())
        setVechicleHandling(getGoldCarrier())
    end
end)

function onRepairCar(player)
    -- showPlayerParalyzied(getBombHolder(), player)
end
addEvent("repairCar", true)
addEventHandler("repairCar", getRootElement(), onRepairCar)

