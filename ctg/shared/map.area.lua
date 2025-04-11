local mapAreaKey = "mapArea"

function getMapArea()
    return getElementData(resourceRoot, mapAreaKey)
end

function setMapArea(area)
    setElementData(resourceRoot, mapAreaKey, area)
end

function isInsideMapArea(x, y, z)
    local area = getMapArea()
    return x >= area.xMin and x <= area.xMax and y >= area.yMin and y <= area.yMax
end