local goldCarrier = nil

function getGoldCarrier()
	return goldCarrier
end

-- Since we listen for events on the root element we can use the goldCarrier as the source. Events
-- triggered on any element will be catched if we listening to the root element.
function goldCarrierChanged ( oldGoldCarrier )
	goldCarrier = source
end
addEvent("onGoldCarrierChanged", true)
addEventHandler("onGoldCarrierChanged", getRootElement(), goldCarrierChanged)

function onGoldCarrierCleared ( )
	goldCarrier = nil
end
addEvent("goldCarrierCleared", true)
addEventHandler("goldCarrierCleared", getRootElement(), onGoldCarrierCleared)

