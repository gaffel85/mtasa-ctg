local TARGET_NAME_TEXT_ID = 847780
local DISTANCE_TO_TARGET_TEXT_ID = 847781
local lastTargetPosKey = "lastTargetPosKey"

local x = 0.5
local y = 0.02
local r = 170
local g = 199
local b = 88
local alpha = 255
local scale = 2

function updateDescriptionOnBlipsChange()
    local players = getElementsByType("player")
    if not getGoldCarrier() then
        local spawn = getLastGoldSpawn()
        if spawn then
            for k, player in ipairs(players) do
                setElementData(player, lastTargetPosKey, { x = spawn.x, y = spawn.y, z = spawn.z })
            end

            local desc = spawn.desc
            -- if desc not nil and not empty
            if desc and desc ~= "" then
                displayMessageForAll(TARGET_NAME_TEXT_ID, "\""..desc.."\"", nil, nil, 5000000, x, y, r, g, b, alpha, scale)
            else
                displayMessageForAll(TARGET_NAME_TEXT_ID, "Next gold", nil, nil, 5000000, x, y, r, g, b, alpha, scale)
            end
        end
    else
        for k, player in ipairs(players) do
            local hideout = getTeamHideout(player)
            if hideout then
                local desc = hideout.desc
                setElementData(player, lastTargetPosKey, { x = hideout.pos.x, y = hideout.pos.y, z = hideout.pos.z })
                if desc and desc ~= "" then
                    displayMessageForPlayer(player, TARGET_NAME_TEXT_ID, "\""..desc.."\"", 5000000, x, y, r, g, b, alpha, scale)
                else
                    displayMessageForPlayer(player, TARGET_NAME_TEXT_ID, "Your hideout", 5000000, x, y, r, g, b, alpha, scale)
                end
            end
        end
    end
end

--run every half second
