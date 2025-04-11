local mapAreaKey = "mapArea"

function getMapArea()
    return getElementData(resourceRoot, mapAreaKey)
end

function setMapArea(area)
    setElementData(resourceRoot, mapAreaKey, area)
end

function isInsideMapArea(x, y, z)
    local area = getMapArea()
    if not area then
        return true
    end
    return x >= area.xMin and x <= area.xMax and y >= area.yMin and y <= area.yMax
end