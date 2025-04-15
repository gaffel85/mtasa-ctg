local TARGET_NAME_TEXT_ID = 847780
local DISTANCE_TO_TARGET_TEXT_ID = 847781

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
                setPlayerStaticTarget(player, spawn.x, spawn.y, spawn.z)
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

            if getGoldCarrier() == player then
                if hideout then
                    setPlayerStaticTarget(player, hideout.pos.x, hideout.pos.y, hideout.pos.z)
                else
                    setPlayerMovingTarget(player, getGoldCarrier())
                end
            else
                setPlayerMovingTarget(player, getGoldCarrier())
            end

            if hideout then
                local desc = hideout.desc
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
