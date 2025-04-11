PowerPickupRepo = {
    pickups = {},
}

PowerPickup = {}
PowerPickup.__index = PowerPickup
-- Create a new QuadTree
function PowerPickup.new(powerKey)
    local self = setmetatable({}, PowerPickup)
    self.powerKey = powerKey
    return self
end

function PowerPickup:placeAt(x, y, z)
    self.marker = createMarker(x, y, z, "ring", 3)
    self.eventHandler = function(hitElement)
        local elementType = getElementType(hitElement)
        if elementType == "player" then
            outputChatBox("Player has entered marker.")
            self:pickedUp(hitElement)
        elseif elementType == "vehicle" then
            local driver = getVehicleController(hitElement)
            if driver then
                outputChatBox("Vehicle has entered marker with driver: " .. getPlayerName(driver))
                self:pickedUp(driver)
            end
        end
    end
    addEventHandler("onMarkerHit", playerMarker, self.eventHandler)
end

function PowerPickup:pickedUp(player)
    if self.eventHandler then
        removeEventHandler("onMarkerHit", self.marker, self.eventHandler)
    end
    if isElement(self.marker) then
        destroyElement(self.marker)
    end

    local oldConfig = getPlayerPowerConfig(player)
    oldConfig.owned = { self.powerKey }
    oldConfig.active = { { key = self.powerKey, bindKey = "X" }, }
    setPlayerPowerConfig(player, oldConfig)
end

function PowerPickupRepo:createRandomPickup(x, y, z)
    local allPowers = getAllPowers()
    local power = allPowers[math.random(1, #allPowers)]
    local pickup = PowerPickup:new(power.key)
    pickup:placeAt(x, y, z)
    table.insert(self.pickups, pickup)
    return pickup
end