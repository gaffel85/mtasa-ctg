-- Redundant shadowing of getGoldCarrier removed to favor synced shared/data/goldcarrier.shared.lua
-- The shared version uses getElementData(resourceRoot) which is synced across all clients.

function goldCarrierChanged ( oldGoldCarrier )
    -- Source is the new carrier. Shared state is already synced via elementData.
end
addEvent("onGoldCarrierChanged", true)
addEventHandler("onGoldCarrierChanged", getRootElement(), goldCarrierChanged)

function onGoldCarrierCleared ( )
end
addEventHandler("goldCarrierCleared", getRootElement(), onGoldCarrierCleared)

