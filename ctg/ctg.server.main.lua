local spawnPoints
local currentSpawn = 1

local goldCarrier
local previousGoldCarrier
local previousGoldCarrierResetter
local participants = {}
local blowingPlayer = nil

local SCORE_KEY = "Score"

local currentVehicle = 1
local vehicles = {415, 551, 531, 475, 437, 557}

addEvent("bombHolderChanged")
addEvent("goldDelivered")

scoreboardRes = getResourceFromName("scoreboard")

function nextVehicle()
    currentVehicle = currentVehicle % #vehicles + 1
end

function getCurrentVehicle()
    return vehicles[currentVehicle]
end

function getGoldCarrier()
    return goldCarrier
end

function setGoldCarrier(player)
    outputChatBox("1")
    if (player == goldCarrier) then
        return
    end

    local oldGoldCarrier = goldCarrier
    if (oldGoldCarrier ~= nil) then
        removeVehicleUpgrade(getPedOccupiedVehicle(oldGoldCarrier), 1009)
    end

    goldCarrier = player
	givePointsToPlayer(goldCarrier, 50)
    triggerClientEvent("onGoldCarrierChanged", player, oldGoldCarrier)

    showPresentGoldCarrier(goldCarrier)
    fixVehicle(getPedOccupiedVehicle(player))

    triggerEvent("goldCarrierChanged", goldCarrier, oldGoldCarrier)

    outputChatBox("2")
    spawnNewHideout()
end

function clearGoldCarrier()
    goldCarrier = nil
    triggerEvent("onGoldCarrierCleared", root)
end

function goldDelivered()
    givePointsToPlayer(goldCarrier, 500)
    triggerEvent("goldDelivered", root, goldCarrier, 500)
    activeRoundFinished()
end

-- Stop player from exiting vehicle
function exitVehicle(thePlayer, seat, jacked)
    cancelEvent()
end
addEventHandler("onVehicleStartExit", getRootElement(), exitVehicle)

function spawn(thePlayer)
    local spawnPoint = spawnPoints[currentSpawn]
    currentSpawn = currentSpawn % #spawnPoints + 1
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
        if (veh ~= nil and veh ~= false ) then
            fixVehicle(veh)
        end
    end
end

function givePointsToPlayer(player, points)
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
    if idx ~= nil then 
        table.remove(tab, idx)
        return true
    end
    return false
end

function contains(tab, val)
    local idx = getIndex(tab, val)
    if idx ~= nil then 
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
    setGoldSpawns(goldSpawnPoints)
    setHideouts(hideouts)

    resetGame()
end
addEventHandler("onGamemodeMapStart", getRootElement(), startGameMap)

function joinHandler()
    spawn(source)
    startGameIfEnoughPlayers()
    outputChatBox("Welcome to Capture the Gold!", source)
end
addEventHandler("onPlayerJoin", getRootElement(), joinHandler)

function startGameIfEnoughPlayers()
    local players = getElementsByType("player")
	if #players < 3 then
        resetGame()
    end
end

function goldDelivered(player)
	givePointsToPlayer(goldCarrier, 500)
	destroyElementsByType ("blip")
	showTextGoldDelivered(goldCarrier)
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

	local players = getElementsByType("player")
    for k, player in ipairs(players) do
		local theVehicle = getPedOccupiedVehicle(player)
        if theVehicle then
			setElementModel(theVehicle, getCurrentVehicle())
		end
    end

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

function playerDied(ammo, attacker, weapon, bodypart)
    local posX, posY, posZ = getElementPosition(source)
    spawnAt(source, posX, posY, posZ, 0, 0, 0)

    showRepairingCar(source)
    toggleAllControls(source, false, true, false)
    onRepairCar(source)
    local theWasted = source
    setTimer(function()
        toggleAllControls(theWasted, true, true, true)
    end, 5000, 1)
end
addEventHandler("onPlayerWasted", getRootElement(), playerDied)

function startSpectating(player)
    triggerClientEvent("startSpectating", player)
end

function coordsFromEdl(element)
    local posX = getElementData(element, "posX")
    local posY = getElementData(element, "posY")
    local posZ = getElementData(element, "posZ")
    return posX or 0, posY or 0, posZ or 0
end

function rotFromEdl(element)
    local posX = getElementData(element, "rotX")
    local posY = getElementData(element, "rotY")
    local posZ = getElementData(element, "rotZ")
    return posX or 0, posY or 0, posZ or 0
end

function quitPlayer(quitType)
end
addEventHandler("onPlayerQuit", getRootElement(), quitPlayer)

function commitSuicide(sourcePlayer)
    -- kill the player and make him responsible for it
    killPed(sourcePlayer, sourcePlayer)
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

addCommandHandler("changeveh", function(thePlayer, command, newModel)
    local theVehicle = getPedOccupiedVehicle(thePlayer) -- get the vehicle the player is in
    newModel = tonumber(newModel) -- try to convert the string argument to a number
    if theVehicle and newModel then -- make sure the player is in a vehicle and specified a number
        setElementModel(theVehicle, newModel)
    end
end)

addCommandHandler("fixit", function(thePlayer, command, newModel)
    local theVehicle = getPedOccupiedVehicle(thePlayer)
    if theVehicle then
        fixVehicle(theVehicle)
    end
end)

function collisisionWithPlayer(otherPlayer)
    setGoldCarrier(otherPlayer)
end
addEvent("onCollisionWithPlayer", true)
addEventHandler("onCollisionWithPlayer", getRootElement(), collisisionWithPlayer)

function onRepairCar(player)
    showPlayerParalyzied(getBombHolder(), player)
end
addEvent("repairCar", true)
addEventHandler("repairCar", getRootElement(), onRepairCar)

