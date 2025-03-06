local TARGET_NAME_TEXT_ID = 847780
local DISTANCE_TO_TARGET_TEXT_ID = 847781
local lastTargetPos = nil
local lastTargetPosKey = "lastTargetPosKey"

function updateDescriptionOnBlipsChange()
    lastTargetPos = nil
    if not getGoldCarrier() then
        local spawn = getLastGoldSpawn()
        if spawn then
            lastTargetPos = { x = spawn.x, y = spawn.y, z = spawn.z }    
            local desc = spawn.desc
            displayMessageForAll(TARGET_NAME_TEXT_ID, desc, nil, nil, 5000000, 0.5, 0.02, 255, 255, 255, 255, 1)
        end
    else
        local players = getElementsByType("player")
        for k, v in ipairs(players) do
            local hideout = getTeamHideout(player)
            if hideout then
                local desc = hideout.desc
                setElementData(player, lastTargetPosKey, { x = hideout.pos.x, y = hideout.pos.y, z = hideout.pos.z })
                displayMessageForPlayer(player, TARGET_NAME_TEXT_ID, desc, 5000000, 0.5, 0.02, 255, 255, 255, 255, 1)
            end
        end
    end
end

--run every half second
setTimer(function()
    -- cgeck distance for all player to target and display
    local players = getElementsByType("player")
    for k, player in ipairs(players) do
        local targetPos = lastTargetPos
        if getGoldCarrier() then
            targetPos = getElementData(player, lastTargetPosKey)
        end
        if targetPos then
            local x, y, z = getElementPosition(player)
            local distance = getDistanceBetweenPoints3D(x, y, z, targetPos.x, targetPos.y, targetPos.z)
            displayMessageForPlayer(player, DISTANCE_TO_TARGET_TEXT_ID, distance.."m", 1000
            , 0.5, 0.05, 255, 255, 255, 255, 1)
        end
    end
end, 500, 0)