local spawnPoints
local currentSpawn = 1
local participants = {}
local blowingPlayer = nil

local SCORE_KEY = "Score"

--addEvent("goldDelivered")
--addEvent("goldCarrierChanged")

scoreboardRes = getResourceFromName("scoreboard")

function goldPickedUp(player)
    changeGoldCarrier(player)
    showPresentGoldCarrier(getGoldCarrier())
    
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

function spawn(thePlayer, random)
    local spawnPoint = spawnPoints[math.random(#spawnPoints)]
    if (random == true) then
        local spawnPoint = spawnPoints[currentSpawn]
        currentSpawn = currentSpawn % #spawnPoints + 1
    end  
    spawnAtSpawnpoint(thePlayer, spawnPoint)
end

function spawnAtSpawnpoint(thePlayer, spawnPoint)
    local posX, posY, posZ = coordsFromEdl(spawnPoint)

    local radius = 20
    local locations = {}
    while #locations == 0 do
        locations = getLocations(posX, posY, posZ, radius)
        radius = radius + 10
    end

    local location = locations[math.random(#locations)]
    local posX, posY, posZ, rotX, rotY, rotZ = location.x, location.y, location.z, location.rx, location.ry, location.rz

    if posX == 0 then
        posX, posY, posZ = coordsFromEdl(spawnPoint)
        rotX, rotY, rotZ = rotFromEdl(spawnPoint)
    end
    spawnAt(thePlayer, posX, posY, posZ, rotX, rotY, rotZ)
end

function spawnAt(player, posX, posY, posZ, rotX, rotY, rotZ)
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
        spawn(v)
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

function givePointsToPlayer(player, points)
    giveTeamScore(player, points)
    local score = getElementData(player, SCORE_KEY)
    if (score == false) then
        score = 0
    end
    score = score + points
    setElementData(player, SCORE_KEY, score)
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

function startGameMap(startedMap)
    outputServerLog("Starging map "..inspect(getElementID(startedMap)))
    local mapRoot = getResourceRootElement(startedMap)
    spawnPoints = getElementsByType("playerSpawnPoint", mapRoot)
    goldSpawnPoints = getElementsByType("goldSpawnPoint", mapRoot)
    hideouts = getElementsByType("hideout", mapRoot)
    local mapIdElements = getElementsByType("mapid", mapRoot)
    if mapIdElements == nil or #mapIdElements == 0 then
        mapId = "ctg-global"
    else 
        mapId = getElementID(mapIdElement[1])
    end
    
    currentSpawn = math.random(#spawnPoints)
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
    local oldHideout = getCtgTeam(getGoldCarrier()).hideout
    removeOldHideout()
	givePointsToPlayer(getGoldCarrier(), 500)
    -- triggerEvent("goldDelivered", root, getGoldCarrier(), 500)
	showTextGoldDelivered(getGoldCarrier())

    local newGoldEdl = prepareNextGold()
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
    local gatherTime = math.min(getConst().goldSpawnTime, getConst().gatherTime)
    gatherPlayersAt(x, y, z, 100, gatherTime)

    scheduleNextGold(getConst().goldSpawnTime)
end

function resetRoundVars()
    resetPowerStatesOnDeliverd()
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

function resetScore()
    local players = getElementsByType("player")
    for k, v in ipairs(players) do
        setElementData(v, SCORE_KEY, 0)
    end
end



function playerDied(player)
    local posX, posY, posZ = getElementPosition(player)
    if player == getGoldCarrier() then
        clearGoldCarrier()
      -- outputChatBox("had position"..inspect(posX))
        spawnGoldAtTransform(posX, posY, posZ)
        refreshAllBlips()
    end
    local closestSpawn = positionCloseTo(spawnPoints, {x = posX, y = posY, z = posZ}, 0)
    spawnAtSpawnpoint(player, closestSpawn)
end

function playerWastedMain(ammo, attacker, weapon, bodypart)
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
addEvent("reportLastTransform", true)
addEvent("reportTransform", true)
addEventHandler("reportTransform", resourceRoot, function(transform, param1, param2, param3)
    if param1 and param1 == "replaceGold" then
        spawnGoldAtTransform(transform.x, transform.y, transform.z)
        refreshAllBlips()
    end
    if param1 and param1 == "telportTo" then
        -- outputChatBox(inspect(param2).." "..inspect(param3))
        teleportTo(param2, transform)
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

function commitSuicide(sourcePlayer)
    -- kill the player and make him responsible for it
    killPed(sourcePlayer, sourcePlayer)
    playerDied(sourcePlayer)
end
addCommandHandler("kill", commitSuicide)

addEvent("onDisplayClientText", true)
addEventHandler("onDisplayClientText", resourceRoot, displayMessageForPlayer)

addEvent("onClearClientText", true)
addEventHandler("onClearClientText", getRootElement(), clearMessageForPlayer)

addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), function()
    call(scoreboardRes, "removeScoreboardColumn", SCORE_KEY)
end)

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), function()
    call(scoreboardRes, "addScoreboardColumn", SCORE_KEY)
end)

addCommandHandler("fixit", function(thePlayer, command, newModel)
    local theVehicle = getPedOccupiedVehicle(thePlayer)
    if theVehicle then
        fixVehicle(theVehicle)
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

