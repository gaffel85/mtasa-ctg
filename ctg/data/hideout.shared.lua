local HIDEOUT_DATA_KEY = "HIDEOUT_DATA_KEY"
local cachedHideouts = {}

function getHideoutDataKey()
    return HIDEOUT_DATA_KEY
end

function setCachedHideout(teamElement, hideout)
    cachedHideouts[teamElement] = hideout
end

function getHideoutData(teamElement)
    if cachedHideouts[teamElement] then
        return cachedHideouts[teamElement]
    end
    local hideout = getElementData(teamElement, HIDEOUT_DATA_KEY)
    if (hideout == false) then
        return nil
    end
    return hideout
end


