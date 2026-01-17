function setGoldCarrierData(player)
    local oldGoldCarrier = getGoldCarrier()
    setElementData(resourceRoot, getGoldCarrierDataKey(), player)
    setCachedGoldCarrier(player)
    return oldGoldCarrier
end