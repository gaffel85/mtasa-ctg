function chooseRandomCloseToByLimits(edls, position, wantedRadius, safeDeviation, minRadius)
    local edlsWithDistances = edlsWithDistance(edls, position, wantedRadius)
    local longestDistance = findLongestDistance(edlsWithDistances)

    local hardMinDist = wantedRadius - safeDeviation
    -- random value between minRadius and hardMinDist
    local choosenMinDist = math.random() * (hardMinDist - minRadius) + minRadius

    local hardMaxDist = wantedRadius + safeDeviation
    -- random value between wantedRadius and longestDistance
    local choosenMaxDist = math.random() * (longestDistance - wantedRadius) + wantedRadius

    -- filter out all edls that are not in the range
    local filteredEdls = {}
    for i, v in ipairs(edlsWithDistances) do
        if v.distance >= choosenMinDist and v.distance <= choosenMaxDist then
            table.insert(filteredEdls, v)
        end
    end

    if #filteredEdls == 0 then
        -- pick random of all edls
        return edls[math.random(1, #edls)]
    end

    -- pick random of the filtered edls
    return filteredEdls[math.random(1, #filteredEdls)].edl
end

function edlsWithDistance(edls, position, radius)
    local edlsWithDistances = {}
    for i, edl in ipairs(edls) do
        local x, y, z = coordsFromEdl(edl)
        local distance = getDistanceBetweenPoints3D(x, y, z, position.x, position.y, position.z)
        local distanceFromRadius = math.abs(distance - radius)
        table.insert(edlsWithDistances, {edl = edl, deviation = distanceFromRadius, distance = distance, x = x, y = y, z = z})
    end
    return edlsWithDistances
end

function findLongestDistance(edlsWithDistances)
    local longestDistance = 0
    for i, v in ipairs(edlsWithDistances) do
        if v.distance > longestDistance then
            longestDistance = v.distance
        end
    end
    return longestDistance

end

function chooseRandomCloseTo(edls, position, wantedRadius)

    -- create a new table with the edls and their distances to the position
    local edlsWithDistances = edlsWithDistance(edls, position, wantedRadius)
    local longestDistance = findLongestDistance(edlsWithDistances)

    for i, v in ipairs(edlsWithDistances) do
        v.quota = longestDistance + 200 - v.deviation
    end

    -- sort the table by longest distance first
    table.sort(edlsWithDistances, function(a, b) return a.quota > b.quota end)

    -- pick a random element based on quota where the quota is the index in the table
    local totalQuota = 0
    for _, v in ipairs(edlsWithDistances) do
        totalQuota = totalQuota + v.quota
    end

    -- get a random number between 0 and totalQuota
    local random = math.random() * totalQuota
    -- iterate over the table and subtract the quota of each element from the random number
    for k, v in pairs(edlsWithDistances) do
        random = random - v.quota
        -- if the random number is less than 0, return the edl
        if random < 0 then
            return v.edl
        end
    end

    return nil
end

function positionCloseTo(edls, firstPosition, firstRadius, secondPosition, secondRadius, secondWeight)
    if not edls or #edls == 0 then
        return nil
    end

    local edlsWithDistances = {}
    for i, edl in ipairs(edls) do
        local x, y, z = coordsFromEdl(edl)
        local distance = getDistanceBetweenPoints3D(x, y, z, firstPosition.x, firstPosition.y, firstPosition.z)
        local distanceFromRadius = math.abs(distance - firstRadius)

        local secondDistance = -1
        if secondPosition then
            local distance2 = getDistanceBetweenPoints3D(x, y, z, secondPosition.x, secondPosition.y, secondPosition.z)
            secondDistance = math.abs(distance2 - secondRadius)
        end

        table.insert(edlsWithDistances, {edl = edl, distance = distanceFromRadius, x, y, z, secondDistance = secondDistance})
    end

    if secondWeight then
        table.sort(edlsWithDistances, function(a, b) 
            return (a.distance + a.secondDistance * secondWeight) < (b.distance + b.secondDistance * secondWeight)
        end)
    else
        table.sort(edlsWithDistances, function(a, b) 
            return a.distance < b.distance 
        end)
    end
    return edlsWithDistances[1].edl
end

function meanPositionOfPlayers()
    local players = getElementsByType("player")
    return meanPositionAndRotationOfElements(players)
end

function meanPositionAndRotationOfElements(elements)
    if #elements == 0 then
        outputServerLog("No elements found")
        return {x = 0, y = 0, z = 0, rotationZ = 0}
    end

    local x, y, z = 0, 0, 0
    local meanRotationZ = 0
    for i, element in ipairs(elements) do
        local posX, posY, posZ = getElementPosition(element)
        x = x + posX
        y = y + posY
        z = z + posZ
        local _, _, rz = getElementRotation(element)
        meanRotationZ = meanRotationZ + rz
    end
    return {x = x / #elements, y = y / #elements, z = z / #elements, rotationZ = meanRotationZ / #elements}
end

function playersExceptMe(me)
    local players = getElementsByType("player")
    local playersExceptMe = {}
    for i, player in ipairs(players) do
        if player ~= me then
            table.insert(playersExceptMe, player)
        end
    end
    return playersExceptMe
end