-- ctg/client/gold.marker.lua

-- Robust marker visibility check
function updateGoldMarkerVisibility(marker)
    if not isElement(marker) or getElementType(marker) ~= "marker" then return end
    if not getElementData(marker, "isGoldCarrierMarker") then return end

    -- Use the synced getGoldCarrier() (from data/goldcarrier.shared.lua)
    local carrier = getGoldCarrier()
    
    if carrier == localPlayer then
        setElementAlpha(marker, 0)
        setMarkerSize(marker, 0)
    else
        setElementAlpha(marker, 255)
        setMarkerSize(marker, 2.0)
    end
end

function refreshAllMarkers()
    for _, marker in ipairs(getElementsByType("marker")) do
        updateGoldMarkerVisibility(marker)
    end
end

-- 1. Check when a marker streams in (attached markers can stream in/out)
addEventHandler("onClientElementStreamIn", getRootElement(), function()
    if getElementType(source) == "marker" then
        updateGoldMarkerVisibility(source)
        -- Delayed checks to ensure element data is fully synced on client
        setTimer(updateGoldMarkerVisibility, 100, 1, source)
        setTimer(updateGoldMarkerVisibility, 1000, 1, source)
    end
end)

-- 2. Listen for carrier changes via synced element data
addEventHandler("onClientElementDataChange", resourceRoot, function(key)
    if key == "GOLD_CARRIER_DATA_KEY" then
        refreshAllMarkers()
        -- Repeat briefly to catch markers that are still initializing
        setTimer(refreshAllMarkers, 100, 5)
    end
end)

-- 3. Listen for marker tag changes
addEventHandler("onClientElementDataChange", getRootElement(), function(key)
    if key == "isGoldCarrierMarker" then
        updateGoldMarkerVisibility(source)
    end
end)

-- 4. Initial check and periodic safety check
addEventHandler("onClientResourceStart", resourceRoot, function()
    refreshAllMarkers()
    -- Periodic check every 2 seconds as a final fallback
    setTimer(refreshAllMarkers, 2000, 0)
end)

-- 5. Support immediate response to carrier change events
addEvent("onGoldCarrierChanged", true)
addEventHandler("onGoldCarrierChanged", getRootElement(), function()
    setTimer(refreshAllMarkers, 100, 1)
end)

addEvent("goldCarrierCleared", true)
addEventHandler("goldCarrierCleared", getRootElement(), function()
    setTimer(refreshAllMarkers, 100, 1)
end)
