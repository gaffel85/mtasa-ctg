DAMAGE_MULTIPLIER_WEIGHT = 1.0

function propertyChangedHandler ( param, value )
	if (param == "DAMAGE_MULTIPLIER_WEIGHT") then
        local oldValue = DAMAGE_MULTIPLIER_WEIGHT
        DAMAGE_MULTIPLIER_WEIGHT = value
        outputChatBox("Damage multiplier weight set to: "..DAMAGE_MULTIPLIER_WEIGHT.." (old was "..oldValue..")")
    end
end
addEvent("onPropertyChanged", true)
addEventHandler("onPropertyChanged", resourceRoot, propertyChangedHandler)