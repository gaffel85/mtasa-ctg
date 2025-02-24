local spawnPoints
local currentSpawn = 1

local tillbakaKakaShield = false
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
    local posX, posY, posZ = coordsFromEdl(spawnPoint)
    local rotX, rotY, rotZ = rotFromEdl(spawnPoint)
    spawnAt(thePlayer, posX, posY, posZ, rotX, rotY, rotZ)
end

function spawnAt(player, posX, posY, posZ, rotX, rotY, rotZ)
    -- posX="" posY="" posZ=""
    -- local vehicle = createVehicle(551, -1982.86, 112.54, 27.68, 0, 0, 0, "BOMBER")
    local vehicle = createVehicle(getCurrentVehicle(), posX, posY, posZ, rotX, rotY, rotZ, "BOMBER")
    -- local vehicle = createVehicle(getCurrentVehicle(), posX, posY, posZ, 0, 0, 0, "BOMBER")
    spawnPlayer(player, 0, 0, 0, 0, 285)
    setTimer(function()
        warpPedIntoVehicle(player, vehicle)
        fadeCamera(player, true)
        setCameraTarget(player, player)
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
        if (v.id == val) then
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
    local mapRoot = getResourceRootElement(startedMap)
    spawnPoints = getElementsByType("playerSpawnPoint", mapRoot)
    goldSpawnPoints = getElementsByType("goldSpawnPoint", mapRoot)
    hideouts = getElementsByType("hideout", mapRoot)
    currentSpawn = math.random(#spawnPoints)
    setGoldSpawns(goldSpawnPoints)
    setHideouts(hideouts)
    plotPoints()
    resetGame()
end
addEventHandler("onGamemodeMapStart", getRootElement(), startGameMap)

function  plotPoints()
    outputChatBox("Plotting points")
    for k, goldSpawn in ipairs(goldSpawnPoints) do
        local posX, posY, posZ = coordsFromEdl(goldSpawn)
        createBlip(posX, posY, posZ, 0, 2, 0, 255, 255, 255, 0)
    end
    for k, hideout in ipairs(hideouts) do
        local posX, posY, posZ = coordsFromEdl(hideout)
        createBlip(posX, posY, posZ, 0, 2, 0, 0, 255, 255, 0)
    end
end

function joinHandler()
    spawn(source, false)
    startGameIfEnoughPlayers()
    outputChatBox("Welcome to Capture the Gold!", source)
    refreshAllBlips()
    plotPoints()
end
addEventHandler("onPlayerJoin", getRootElement(), joinHandler)

function startGameIfEnoughPlayers()
    local players = getElementsByType("player")
	if #players < 3 then
        --resetGame()
    end
end

function goldDelivered(player)
    removeOldHideout()
	givePointsToPlayer(getGoldCarrier(), 500)
    -- triggerEvent("goldDelivered", root, getGoldCarrier(), 500)
	showTextGoldDelivered(getGoldCarrier())
    activeRoundFinished()
end

function placeGold()
	spawnNewGold()
end

function startActiveRound()
    repairAllCars()
    resetRoundVars()
end

function activeRoundFinished()
    nextVehicle()
    resetRoundVars()
	setTimer(placeGold, 2000, 1, source)
end

function resetGame()
    removeOldHideout()
    removeOldGold()
    resetScore()
    repairAllCars()
    respawnAllPlayers()
	startActiveRound()
	setTimer(placeGold, 2000, 1, source)
end

function resetScore()
    local players = getElementsByType("player")
    for k, v in ipairs(players) do
        setElementData(v, SCORE_KEY, 0)
    end
end

function resetRoundVars()
    clearGoldCarrier()
end

function playerDied(player)
    outputChatBox("Died")
    if player == getGoldCarrier() then
        clearGoldCarrier()
        local posX, posY, posZ = getElementPosition(player)
        outputChatBox("had position"..inspect(posX))
        spawnGoldAtTransform(posX, posY, posZ)
        refreshAllBlips()
    end
    spawn(player, true)
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
        local oldValue = GOLD_HANDLING_COEFF
        GOLD_HANDLING_COEFF = newValue
        outputChatBox("Gold handling coeff set to: "..GOLD_HANDLING_COEFF.." (old was "..oldValue..")")
    end
    if (paramName == "height") then
        local newValue = tonumber(paramValue)
        local oldValue = GOLD_HEIGHT
        GOLD_HEIGHT = newValue
        outputChatBox("Gold height set to: "..GOLD_HEIGHT.." (old was "..oldValue..")")
    end
    if (paramName == "mass") then
        local newValue = tonumber(paramValue)
        local oldValue = GOLD_MASS
        GOLD_MASS = newValue
        outputChatBox("Gold mass set to: "..GOLD_MASS.." (old was "..oldValue..")")
    end
    if (paramName == "damage") then
        local newValue = tonumber(paramValue)
        triggerClientEvent("onPropertyChanged", getRootElement(), "DAMAGE_MULTIPLIER_WEIGHT", newValue)
    end
    local carrier = getGoldCarrier()
    if (carrier) then
        removeVechicleHandling(getGoldCarrier())
        setVechicleHandling(getGoldCarrier())
    end
end)

function collisisionWithPlayer(otherPlayer, damage)
    changeGoldCarrier(otherPlayer)
end
addEvent("onCollisionWithPlayer", true)
addEventHandler("onCollisionWithPlayer", getRootElement(), collisisionWithPlayer)

function onRepairCar(player)
    -- showPlayerParalyzied(getBombHolder(), player)
end
addEvent("repairCar", true)
addEventHandler("repairCar", getRootElement(), onRepairCar)

