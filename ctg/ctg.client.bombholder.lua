local bombHolder = nil

function getBombHolder()
	return bombHolder
end

-- Since we listen for events on the root element we can use the bombHolder as the source. Events
-- triggered on any element will be catched if we listening to the root element.
function bombHolderChanged ( oldBombHolder )
	bombHolder = source
end
addEvent("onBombHolderChanged", true)
addEventHandler("onBombHolderChanged", getRootElement(), bombHolderChanged)

function onBombHolderCleared ( )
	bombHolder = nil
end
addEvent("bombHolderCleared", true)
addEventHandler("bombHolderCleared", getRootElement(), onBombHolderCleared)

