local currentVehicle = 526
local CHANGE_VECHICLE_TEXT_ID = 963781
local voteScreen = nil
local vote1VehicleName = nil
local vote2VehicleName = nil
local vote3VehicleName = nil
local vote1VehicleType = nil
local vote2VehicleType = nil
local vote3VehicleType = nil
local vote1Model = nil
local vote2Model = nil
local vote3Model = nil
local vote1Count = 0
local vote2Count = 0
local vote3Count = 0

local quota = {
    ["Airplanes"] = 0.1,
    ["Helicopters"] = 0.1,
    ["Boats"] = 0,
    ["Bikes"] = 0,
    ["2-Door & Compact cars"] = 1,
    ["4-Door & Luxury cars"] = 1,
    ["Civil service"] = 1,
    ["Government vehicles"] = 1,
    ["Heavy & Utility trucks"] = 1,
    ["Light trucks & Vans"] = 1,
    ["SUVs & Wagons"] = 1,
    ["Lowriders"] = 1,
    ["Muscle cars"] = 1,
    ["Street racers"] = 1,
    ["RC Vehicles"] = 1,
    ["Trailers"] = 0,
    ["Trains & Railroad cars"] = 0,
    ["Recreational"] = 1,
}

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
			outputChatBox("Random: "..inspect(result).." "..inspect(k))
			return result
        end
    end
end

function setVehicleForAll()
    displayMessageForAll(CHANGE_VECHICLE_TEXT_ID, "New vehicle is "..getVehicleNameFromModel(currentVehicle), nil, nil, 3000, 0.5, 0.7, 88, 255, 120)
	local players = getElementsByType("player")
    for k, player in ipairs(players) do
		local theVehicle = getPedOccupiedVehicle(player)
        if theVehicle then
			setElementModel(theVehicle, getCurrentVehicle())
		end
    end
end

function nextVehicle()
    currentVehicle = getRandomVehicle()
    setVehicleForAll()
end

function getCurrentVehicle()
    return currentVehicle
end

function setupVehicleVote()
    voteScreen = textCreateDisplay ()
    
    local vote1Header = textCreateTextItem ( "Vote F5", 0.35, 0.9, "medium", 128, 200, 180, 255, 2, "center", "top", 255)
    vote1VehicleName = textCreateTextItem ( "Vehicle name", 0.35, 0.94, "medium", 90, 150, 220, 255, 2, "center", "top", 255)
    vote1VehicleType = textCreateTextItem ( "Vehicle type", 0.35, 0.97, "small", 90, 150, 220, 255, 2, "center", "top", 255)
    textDisplayAddText ( voteScreen, vote1Header )
    textDisplayAddText ( voteScreen, vote1VehicleName )
    textDisplayAddText ( voteScreen, vote1VehicleType )

    local vote2Header = textCreateTextItem ( "Vote F6", 0.5, 0.9, "medium", 128, 200, 180, 255, 2, "center", "top", 255)
    vote2VehicleName = textCreateTextItem ( "Vehicle name", 0.5, 0.94, "medium", 90, 150, 220, 255, 2, "center", "top", 255)
    vote2VehicleType = textCreateTextItem ( "Vehicle type", 0.5, 0.97, "small", 90, 150, 220, 255, 2, "center", "top", 255)
    textDisplayAddText ( voteScreen, vote2Header )
    textDisplayAddText ( voteScreen, vote2VehicleName )
    textDisplayAddText ( voteScreen, vote2VehicleType )

    local vote3Header = textCreateTextItem ( "Vote F7", 0.65, 0.9, "medium", 128, 200, 180, 255, 2, "center", "top", 255)
    vote3VehicleName = textCreateTextItem ( "Vehicle name", 0.65, 0.94, "medium", 90, 150, 220, 255, 2, "center", "top", 255)
    vote3VehicleType = textCreateTextItem ( "Vehicle type", 0.65, 0.97, "small", 90, 150, 220, 255, 2, "center", "top", 255)
    textDisplayAddText ( voteScreen, vote3Header )
    textDisplayAddText ( voteScreen, vote3VehicleType )
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), setupVehicleVote)

addCommandHandler("changeveh", function(thePlayer, command, newModel)
    local theVehicle = getPedOccupiedVehicle(thePlayer) -- get the vehicle the player is in
    newModel = tonumber(newModel) -- try to convert the string argument to a number
    if theVehicle and newModel then -- make sure the player is in a vehicle and specified a number
        setElementModel(theVehicle, newModel)
    end
end)

addEvent("voteFinnished")
function startVote()
    vote1Model = getRandomVehicle()
    vote2Model = getRandomVehicle()
    vote3Model = getRandomVehicle()

    outputChatBox("Stating poll "..inspect(startPoll))
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
        [4]={"Keep current", "voteFinnished", currentVehicle}
    }

    
    --textItemSetText(vote1VehicleName, getVehicleNameFromModel(vote1Model))
    --textItemSetText(vote2VehicleName, getVehicleNameFromModel(vote2Model))
    --textItemSetText(vote3VehicleName, getVehicleNameFromModel(vote3Model))

    --textItemSetText(vote1VehicleType, getVehicleCategory(vote1Model))
    --textItemSetText(vote2VehicleType, getVehicleCategory(vote2Model))
    --textItemSetText(vote3VehicleType, getVehicleCategory(vote3Model))

    --local players = getElementsByType("player")
    --for k, player in ipairs(players) do
		--textDisplayAddObserver(voteScreen, player)
    --end
    
end

function checkVoteResult(player)
    textDisplayRemoveObserver(voteScreen, player)

    local players = getElementsByType("player")
    local totalPossibleVotes = #players
    -- check if any cote is more than 50%
    local limit = totalPossibleVotes * 0.75
    local allVotesGiven = vote1Count + vote2Count + vote3Count == totalPossibleVotes
    local nextVehicle = nil
    if vote1Count > limit or (allVotesGiven and vote1Count > vote2Count and vote1Count > vote3Count) then
        nextVehicle = vote1Model
    elseif vote2Count > limit or (allVotesGiven and vote2Count > vote1Count and vote2Count > vote3Count) then
        nextVehicle = vote2Model
    elseif vote3Count > limit or (allVotesGiven and vote3Count > vote2Count and vote3Count > vote1Count) then
        nextVehicle = vote3Model
    end

    if (nextVehicle) then
        currentVehicle = nextVehicle
        setVehicleForAll()
        vote1Count = 0
        vote2Count = 0
        vote3Count = 0

        local players = getElementsByType("player")
        for k, player in ipairs(players) do
	    	textDisplayRemoveObserver(voteScreen, player)
         end
    end
end

addEventHandler("voteFinnished", getResourceRootElement(getThisResource()), function(nextVehicle)
    if nextVehicle == currentVehicle then
        return
    end

    currentVehicle = nextVehicle
    setVehicleForAll()
    vote1Count = 0
    vote2Count = 0
    vote3Count = 0

    local players = getElementsByType("player")
    for k, player in ipairs(players) do
      textDisplayRemoveObserver(voteScreen, player)
    end
end)

function vote1(player)
    vote1Count = vote1Count + 1
    checkVoteResult(player)
end

function vote2(player)
    vote2Count = vote2Count + 1
    checkVoteResult(player)
end

function vote3(player)
    vote3Count = vote3Count + 1
    checkVoteResult(player)
end

function bindTheKeys ( )
    bindKey ( source, "F4", "up", startVote, source )
    bindKey ( source, "F5", "up", vote1, source )
    bindKey ( source, "F6", "up", vote2, source ) 
    bindKey ( source, "F7", "up", vote3, source ) end
addEventHandler("onPlayerJoin", getRootElement(), bindTheKeys)

  --unbind on quit
function unbindTheKeys ( )
    unbindKey ( source, "F4" )
    unbindKey ( source, "F5" )
    unbindKey ( source, "F6" ) 
    unbindKey ( source, "F7" )
    textDisplayRemoveObserver ( voteScreen, source )
end
addEventHandler("onPlayerQuit", getRootElement(), unbindTheKeys)