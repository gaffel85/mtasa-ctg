local VEHICLE_BOUNDING_BOX_KEY = "VEHICLE_BOUNDING_BOX_KEY"
local defaultSide = 7

function getVehicleBoundingBoxData(vechilce)
    local bb = getElementData(vechilce, VEHICLE_BOUNDING_BOX_KEY)
    if not bb then
        return defaultSide, -defaultSide, -defaultSide, -defaultSide, defaultSide, defaultSide, defaultSide
    end
    return bb.radius, bb.minx, bb.miny, bb.minz, bb.maxx, bb.maxy, bb.maxz
end
