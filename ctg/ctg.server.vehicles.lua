local currentVehicle = 415
local CHANGE_VECHICLE_TEXT_ID = 963781
local playersToKeepTheirVehicle = {}

function getQuota()
    return {
      ["Airplanes"] = getConst().airplaneQuota,
      ["Helicopters"] = getConst().helicopterQuota,
      ["Boats"] = 0,
      ["Bikes"] = 0,
      ["2-Door & Compact cars"] = getConst().door4Quota,
      ["4-Door & Luxury cars"] = getConst().door4Quota,
      ["Civil service"] = getConst().civilQuota,
      ["Government vehicles"] = getConst().govermentQuota,
      ["Heavy & Utility trucks"] = getConst().heavyQuota,
      ["Light trucks & Vans"] = getConst().vansQuota,
      ["SUVs & Wagons"] = getConst().suvQuota,
      ["Lowriders"] = getConst().lowRidersQuota,
      ["Muscle cars"] = getConst().muscleQuota,
      ["Street racers"] = getConst().streetRacersQuota,  
      ["RC Vehicles"] = 0,
      ["Trailers"] = 0,
      ["Trains & Railroad cars"] = 0,
      ["Recreational"] = getConst().recreationalQuota,
  }
end

local vehiclesByType = {
	{
	  category = "Airplanes",
	  ids = { 592, 577, 511, 512, 593, 520, 553, 476, 519, 460, 513 }
	},
	{
	  category = "Helicopters",
	  ids = { 548, 425, 417, 487, 488, 497, 563, 447, 469 }
	},
	{
	  category = "Boats",
	  ids = { 472, 473, 493, 595, 484, 430, 453, 452, 446, 454 }
	},
	{
	  category = "Bikes",
	  ids = { 581, 509, 481, 462, 521, 463, 510, 522, 461, 448, 468, 586 }
	},
	{
	  category = "2-Door & Compact cars",
	  ids = { 602, 496, 401, 518, 527, 589, 419, 587, 533, 526, 474, 545, 517, 410, 600, 436, 439, 549, 491 }
	},
	{
	  category = "4-Door & Luxury cars",
	  ids = { 445, 604, 507, 585, 466, 492, 546, 551, 516, 467, 426, 547, 405, 580, 409, 550, 566, 540, 421, 529 }
	},
	{
	  category = "Civil service",
	  ids = { 485, 431, 438, 437, 574, 420, 525, 408, 552 }
	},
	{
	  category = "Government vehicles",
	  ids = { 416, 433, 427, 490, 528, 407, 544, 523, 470, 596, 598, 599, 597, 432, 601, 428 }
	},
	{
	  category = "Heavy & Utility trucks",
	  ids = { 499, 609, 498, 524, 532, 578, 486, 406, 573, 455, 588, 403, 423, 414, 443, 515, 514, 531, 456 }
	},
	{
	  category = "Light trucks & Vans",
	  ids = { 459, 422, 482, 605, 530, 418, 572, 582, 413, 440, 543, 583, 478, 554 }
	},
	{
	  category = "SUVs & Wagons",
	  ids = { 579, 400, 404, 489, 505, 479, 442, 458 }
	},
	{
	  category = "Lowriders",
	  ids = { 536, 575, 534, 567, 535, 576, 412 }
	},
	{
	  category = "Muscle cars",
	  ids = { 402, 542, 603, 475 }
	},
	{
	  category = "Street racers",
	  ids = { 429, 541, 415, 480, 562, 565, 434, 494, 502, 503, 411, 559, 506, 451, 558, 555, 477 }
	},
	{
	  category = "RC Vehicles",
	  ids = { 441, 464, 594, 501, 465, 564 }
	},
	{
	  category = "Trailers",
	  ids = { 606, 607, 610, 584, 611, 608, 435, 450, 591 }
	},
	{
	  category = "Trains & Railroad cars",
	  ids = { 590, 538, 570, 569, 537, 449 }
	},
	{
	  category = "Recreational",
	  ids = { 568, 424, 504, 457, 483, 508, 571, 500, 444, 556, 557, 495 }
	}
}

function getVehicleCategory(vehicleId)
    for k, v in pairs(vehiclesByType) do
		for k1, v1 in pairs(v.ids) do
			if v1 == vehicleId then
				return v.category
			end
		end
    end
end

function findVehicleListByCategory(category)
    for k, v in pairs(vehiclesByType) do
        if v.category == category then
            return v.ids
        end
    end
end

function getRandomVehicle()
    local quota = getQuota()
    local totalQuota = 0
    for k, v in pairs(quota) do
        totalQuota = totalQuota + v
    end

    -- get a random number between 0 and totalQuota
    local random = math.random() * totalQuota
    -- iterate over the quota table and subtract the quota of each category from the random number
    for k, v in pairs(quota) do
        random = random - v
        -- if the random number is less than 0, return a random vehicle from the category
        if random < 0 then
            local vehicles = findVehicleListByCategory(k)
            local result = vehicles[math.random(1, #vehicles)]
			-- outputChatBox("Random: "..inspect(result).." "..inspect(k))
			return result
        end
    end
end

function setVehicleForAll()
  local players = getElementsByType("player")
  for k, player in ipairs(players) do
    if not playersToKeepTheirVehicle[player] then

      displayMessageForPlayer(player, CHANGE_VECHICLE_TEXT_ID, "New vehicle is "..getVehicleNameFromModel(currentVehicle), nil, nil, 3000, 0.5, 0.7, 88, 255, 120)

      setVehicleForPlayer(player, getCurrentVehicle())
    end
  end
end

function setVehicleForPlayer(player, model)
  local theVehicle = getPedOccupiedVehicle(player)
  if theVehicle then
    local r, g, b = getTeamColorForPlayer(player)
    local upgrades = getVehicleUpgrades ( theVehicle )
    setElementModel(theVehicle, model)
    setVehicleColor(theVehicle, r, g, b)
    for _, upgrade in ipairs ( upgrades ) do
      addVehicleUpgrade(theVehicle,  upgrade )
    end
  end
end

function preventChangeFor(player)
  playersToKeepTheirVehicle[player] = true
end

function unpreventChangeFor(player)
  playersToKeepTheirVehicle[player] = nil
end

function nextVehicle()
    currentVehicle = getRandomVehicle()
    setVehicleForAll()
end

function getCurrentVehicle()
    return currentVehicle
end

addCommandHandler("changeveh", function(thePlayer, command, newModel)
    local theVehicle = getPedOccupiedVehicle(thePlayer) -- get the vehicle the player is in
    newModel = tonumber(newModel) -- try to convert the string argument to a number
    if newModel then -- make sure the player is in a vehicle and specified a number
      setVehicleForPlayer(thePlayer, newModel)
    end
end)

addEvent("voteFinnished")
function startVote()
    local vote1Model = getRandomVehicle()
    local vote2Model = getRandomVehicle()
    local vote3Model = getRandomVehicle()

  -- outputChatBox("Stating poll "..inspect(startPoll))
    exports.votemanager:startPoll {
        --start settings (dictionary part)
        title="Vote for next vehicle",
        percentage=75,
        timeout=30,
        allowchange=true,
        maxnominations=2,
        visibleTo=getRootElement(),
        --start options (array part)
        [1]={getVehicleNameFromModel(vote1Model).."["..getVehicleCategory(vote1Model).."]", "voteFinnished", nil, vote1Model},
        [2]={getVehicleNameFromModel(vote2Model).."["..getVehicleCategory(vote2Model).."]", "voteFinnished", nil, vote2Model},
        [3]={getVehicleNameFromModel(vote3Model).."["..getVehicleCategory(vote3Model).."]", "voteFinnished", nil, vote3Model},
        [4]={"Keep current", "voteFinnished", nil, currentVehicle}
    }
end

addEventHandler("voteFinnished", getResourceRootElement(getThisResource()), function(nextVehicle)
    if nextVehicle == currentVehicle then
        return
    end

    currentVehicle = nextVehicle
    setVehicleForAll()
end)

function bindKeysForPlayer(player)
    bindKey(player, "F4", "up", startVote, player)
end

function unbindKeysForPlayer(player)
    unbindKey(player, "F4")
end

function bindTheKeys ( )
    bindKeysForPlayer(source)
end
addEventHandler("onPlayerJoin", getRootElement(), bindTheKeys)

  --unbind on quit
function unbindTheKeys ( )
    unbindKeysForPlayer(source)
end
addEventHandler("onPlayerQuit", getRootElement(), unbindTheKeys)

function bindKeysOnStart()
    for k, player in ipairs(getElementsByType("player")) do
        bindKeysForPlayer(player)
    end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), bindKeysOnStart)

function unbindKeysOnStop()
    for k, player in ipairs(getElementsByType("player")) do
        unbindKeysForPlayer(player)
    end
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), unbindKeysOnStop)