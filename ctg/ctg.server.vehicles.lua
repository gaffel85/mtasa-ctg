local currentVehicle = 526
local CHANGE_VECHICLE_TEXT_ID = 963781
local voteScreen = nil
local vote1VehicleName = nil
local vote2VehicleName = nil
local vote3VehicleName = nil
local vote1Model = nil
local vote2Model = nil
local vote3Model = nil
local vote1Count = 0
local vote2Count = 0
local vote3Count = 0

local twoDoorVehicles = { -- boats and bikes not included
	577, 511, 512, 593, 460, 548, 417, 488, 563, 447, 469,
	602, 496, 401, 518, 527, 589, 419, 587, 533, 526, 474, 545, 517, 410, 600, 436, 439, 549, 491,
	431, 525, 408, 552,
	433, 528, 407, 544, 599, 601,
	499, 524, 578, 573, 455, 403, 423, 414, 443, 515, 514, 456,
	422, 605, 543, 478, 554,
	489, 505, 442,
	536, 575, 534, 535, 576, 412,
	402, 542, 603, 475,
	429, 541, 415, 480, 562, 565, 434, 494, 502, 503, 411, 559, 506, 451, 558, 555, 477,
	538, 537,
	424, 504, 483, 508, 500, 444, 556, 557, 495,
}

fourDoorVehicles = { -- boats and bikes not included
	487, 497,
	445, 604, 507, 585, 466, 492, 546, 551, 516, 467, 426, 547, 405, 580, 409, 550, 566, 540, 421, 529,
	438, 420,
	416, 427, 490, 470, 596, 597, 598, 428,
	609, 498, 
	459, 482, 418, 582, 413, 440,
	579, 400, 404, 479, 458,
	567,
	561, 560,
}

local vehicleCategories = {
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
  

vehicleNames = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perennial", "Sentinel", "Dumper", "Fire Truck", "Trashmaster", "Stretch", "Manana", 
	"Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", 
	"Mr. Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", 
	"Trailer 1", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", 
	"Seasparrow", "Pizzaboy", "Tram", "Trailer 2", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", 
	"Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", 
	"Quadbike", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", 
	"Baggage", "Dozer", "Maverick", "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring Racer", "Sandking", 
	"Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer 2", "Hotring Racer 3", "Bloodring Banger", 
	"Rancher Lure", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stuntplane", "Tanker", "Roadtrain", "Nebula", 
	"Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Towtruck", "Fortune", "Cadrona", "FBI Truck", 
	"Willard", "Forklift", "Tractor", "Combine Harvester", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Brown Streak", "Vortex", "Vincent", 
	"Bullet", "Clover", "Sadler", "Fire Truck Ladder", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility Van", 
	"Nevada", "Yosemite", "Windsor", "Monster 2", "Monster 3", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", 
	"Tahoma", "Savanna", "Bandito", "Freight Train Flatbed", "Streak Train Trailer", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", 
	"AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "Newsvan", "Tug", "Trailer (Tanker Commando)", "Emperor", "Wayfarer", "Euros", "Hotdog", 
	"Club", "Box Freight", "Trailer 3", "Andromada", "Dodo", "RC Cam", "Launch", "Police LS", "Police SF", "Police LV", "Police Ranger", 
	"Picador", "S.W.A.T.", "Alpha", "Phoenix", "Glendale Damaged", "Sadler Damaged", "Baggage Trailer (covered)", 
	"Baggage Trailer (Uncovered)", "Trailer (Stairs)", "Boxville Mission", "Farm Trailer", "Street Clean Trailer"
}

function getVehicleName(id)
    return vehicleNames[id - 399]
end

function getRandomVehicle()
    if math.random(1, 2) == 1 then
        return twoDoorVehicles[math.random(1, #twoDoorVehicles)]
    else
        return fourDoorVehicles[math.random(1, #fourDoorVehicles)]
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
    vote1VehicleName = textCreateTextItem ( "Vehicle name", 0.35, 0.95, "medium", 90, 150, 220, 255, 2, "center", "top", 255)
    textDisplayAddText ( voteScreen, vote1Header )
    textDisplayAddText ( voteScreen, vote1VehicleName )

    local vote2Header = textCreateTextItem ( "Vote F6", 0.5, 0.9, "medium", 128, 200, 180, 255, 2, "center", "top", 255)
    vote2VehicleName = textCreateTextItem ( "Vehicle name", 0.5, 0.95, "medium", 90, 150, 220, 255, 2, "center", "top", 255)
    textDisplayAddText ( voteScreen, vote2Header )
    textDisplayAddText ( voteScreen, vote2VehicleName )

    local vote3Header = textCreateTextItem ( "Vote F7", 0.65, 0.9, "medium", 128, 200, 180, 255, 2, "center", "top", 255)
    vote3VehicleName = textCreateTextItem ( "Vehicle name", 0.65, 0.95, "medium", 90, 150, 220, 255, 2, "center", "top", 255)
    textDisplayAddText ( voteScreen, vote3Header )
    textDisplayAddText ( voteScreen, vote3VehicleName )
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), setupVehicleVote)

addCommandHandler("changeveh", function(thePlayer, command, newModel)
    local theVehicle = getPedOccupiedVehicle(thePlayer) -- get the vehicle the player is in
    newModel = tonumber(newModel) -- try to convert the string argument to a number
    if theVehicle and newModel then -- make sure the player is in a vehicle and specified a number
        setElementModel(theVehicle, newModel)
    end
end)

function startVote()
    vote1Model = getRandomVehicle()
    vote2Model = getRandomVehicle()
    vote3Model = getRandomVehicle()

    textItemSetText(vote1VehicleName, getVehicleName(vote1Model))
    textItemSetText(vote2VehicleName, getVehicleName(vote2Model))
    textItemSetText(vote3VehicleName, getVehicleName(vote3Model))

    local players = getElementsByType("player")
    for k, player in ipairs(players) do
		textDisplayAddObserver(voteScreen, player)
    end
end

function checkVoteResult(player)
    textDisplayRemoveObserver(voteScreen, player)

    local players = getElementsByType("player")
    local totalPossibleVotes = #players
    -- check if any cote is more than 50%
    local nextVehicle = nil
    if vote1Count > totalPossibleVotes / 2 then
        nextVehicle = vote1Model
    elseif vote2Count > totalPossibleVotes / 2 then
        nextVehicle = vote2Model
    elseif vote3Count > totalPossibleVotes / 2 then
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