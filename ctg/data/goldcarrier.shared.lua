local GOLD_CARRIER_DATA_KEY = "GOLD_CARRIER_DATA_KEY"
local cachedGoldCarrier = nil

function getGoldCarrierDataKey()
    return GOLD_CARRIER_DATA_KEY
end

function setCachedGoldCarrier(player)
    cachedGoldCarrier = player
end

function getGoldCarrier()
    if cachedGoldCarrier then
        return cachedGoldCarrier
    end
    local goldCarrier = getElementData(resourceRoot, GOLD_CARRIER_DATA_KEY)
    if (goldCarrier == false) then
        return nil
    end
    return goldCarrier
end