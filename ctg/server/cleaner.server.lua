function cleanStuffInWorld()
    -- get all vehicles
    local vehicles = getElementsByType("vehicle")
    for k, v in ipairs(vehicles) do
        -- if no driver destroy
        if not getVehicleOccupant(v) then
            destroyElement(v)
        end
    end
end

setTimer(cleanStuffInWorld, 10000, 0)