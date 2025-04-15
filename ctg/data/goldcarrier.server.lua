local cachedGoldCarrier = nil

function setGoldCarrierData(player)
    local oldGoldCarrier = getGoldCarrier()
    setElementData(resourceRoot, getGoldCarrierDataKey(), player)
    cachedGoldCarrier = player
    return oldGoldCarrier
end