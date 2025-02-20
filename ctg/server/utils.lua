function chooseRandomCloseTo(edls, position, wantedRadius)

    -- create a new table with the edls and their distances to the position
    local edlsWithDistances = {}
    for i, edl in ipairs(edls) do
        local x, y, z = coordsFromEdl(edl)
        local distance = getDistanceBetweenPoints3D(x, y, z, position.x, position.y, position.z)
        local distanceFromRadius = math.abs(distance - wantedRadius)
        table.insert(edlsWithDistances, {edl = edl, distance = distanceFromRadius, x, y, z})
    end

    -- sort the table by longest distance first
    table.sort(edlsWithDistances, function(a, b) return a.distance > b.distance end)

    -- pick a random element based on quota where the quota is the index in the table
    local totalQuota = 0
    for k, _ in ipairs(edlsWithDistances) do
        totalQuota = totalQuota + k
    end

    -- get a random number between 0 and totalQuota
    local random = math.random() * totalQuota
    -- iterate over the table and subtract the quota of each element from the random number
    for k, v in pairs(edlsWithDistances) do
        random = random - k
        -- if the random number is less than 0, return the edl
        if random < 0 then
            return v.edl
        end
    end

    return nil
end

function meanPositionOfPlayers()
    local players = getElementsByType("player")
    local x, y, z = 0, 0, 0
    for i, player in ipairs(players) do
        x = x + getElementPosition(player).x
        y = y + getElementPosition(player).y
        z = z + getElementPosition(player).z
    end
    return {x = x / #players, y = y / #players, z = z / #players}
end