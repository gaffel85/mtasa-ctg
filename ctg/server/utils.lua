function chooseRandomCloseTo(edls, position, wantedRadius)

    -- create a new table with the edls and their distances to the position
    local edlsWithDistances = {}
    for i, edl in ipairs(edls) do
        local x, y, z = coordsFromEdl(edl)
        local distance = getDistanceBetweenPoints3D(x, y, z, position.x, position.y, position.z)
        local distanceFromRadius = math.abs(distance - wantedRadius)
        table.insert(edlsWithDistances, {edl = edl, distance = distanceFromRadius, x, y, z})
    end

    local longestDistance = 0
    for i, v in ipairs(edlsWithDistances) do
        if v.distance > longestDistance then
            longestDistance = v.distance
        end
    end

    for i, v in ipairs(edlsWithDistances) do
        v.quota = longestDistance + 200 - v.distance
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
        local distance = getDistanceBetweenPoints3D(x, y, z, position.x, position.y, position.z)
        local distanceFromRadius = math.abs(distance - wantedRadius)

        local secondDistance = -1
        if secondPosition then
            local distance2 = getDistanceBetweenPoints3D(x, y, z, secondPosition.x, secondPosition.y, secondPosition.z)
            secondDistance = math.abs(distance2 - secondRadius)
        end

        table.insert(edlsWithDistances, {edl = edl, distance = distanceFromRadius, x, y, z, secondDistance})
    end

    if secondWeight then
        table.sort(edlsWithDistances, function(a, b) 
            return (a.distance + a.secondDistance * secondWeight) > (b.distance + b.secondDistance * secondWeight)
        end)
    else
        table.sort(edlsWithDistances, function(a, b) 
            return a.distance > b.distance 
        end)
    end
    return edlsWithDistances[1].edl
end

function meanPositionOfPlayers()
    local players = getElementsByType("player")
    if #players == 0 then
        return {x = 0, y = 0, z = 0}
    end

    local x, y, z = 0, 0, 0
    for i, player in ipairs(players) do
        local posX, posY, posZ = getElementPosition(player)
        x = x + posX
        y = y + posY
        z = z + posZ
    end
    return {x = x / #players, y = y / #players, z = z / #players}
end