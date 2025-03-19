local QuadTree = {}
QuadTree.__index = QuadTree

-- Create a new QuadTree
function QuadTree.new(xMin, xMax, yMin, yMax, capacity)
    local self = setmetatable({}, QuadTree)
    self.xMin = xMin
    self.xMax = xMax
    self.yMin = yMin
    self.yMax = yMax
    self.capacity = capacity or 4
    self.points = {}
    self.divided = false
    return self
end

-- Subdivide the QuadTree into four quadrants
function QuadTree:subdivide()
    local xMid = (self.xMin + self.xMax) / 2
    local yMid = (self.yMin + self.yMax) / 2

    self.northwest = QuadTree.new(self.xMin, xMid, self.yMin, yMid, self.capacity)
    self.northeast = QuadTree.new(xMid, self.xMax, self.yMin, yMid, self.capacity)
    self.southwest = QuadTree.new(self.xMin, xMid, yMid, self.yMax, self.capacity)
    self.southeast = QuadTree.new(xMid, self.xMax, yMid, self.yMax, self.capacity)

    self.divided = true
end

-- Add a position to the QuadTree
function QuadTree:add(pos)
    if pos.x < self.xMin or pos.x > self.xMax or pos.y < self.yMin or pos.y > self.yMax then
        return false -- Position is out of bounds
    end

    if #self.points < self.capacity then
        table.insert(self.points, pos)
        return true
    else
        if not self.divided then
            self:subdivide()
        end

        if self.northwest:add(pos) then return true end
        if self.northeast:add(pos) then return true end
        if self.southwest:add(pos) then return true end
        if self.southeast:add(pos) then return true end
    end
end

-- Remove a position from the QuadTree
function QuadTree:remove(pos)
    for i, point in ipairs(self.points) do
        if point.x == pos.x and point.y == pos.y then
            table.remove(self.points, i)
            return true
        end
    end

    if self.divided then
        if self.northwest:remove(pos) then return true end
        if self.northeast:remove(pos) then return true end
        if self.southwest:remove(pos) then return true end
        if self.southeast:remove(pos) then return true end
    end

    return false
end

-- Search for the closest position to a given position
function QuadTree:searchClosest(pos, bestPoint, bestDistance)
    for _, point in ipairs(self.points) do
        local distance = math.sqrt((point.x - pos.x)^2 + (point.y - pos.y)^2)
        if not bestDistance or distance < bestDistance then
            bestPoint = point
            bestDistance = distance
        end
    end

    if self.divided then
        bestPoint, bestDistance = self.northwest:searchClosest(pos, bestPoint, bestDistance)
        bestPoint, bestDistance = self.northeast:searchClosest(pos, bestPoint, bestDistance)
        bestPoint, bestDistance = self.southwest:searchClosest(pos, bestPoint, bestDistance)
        bestPoint, bestDistance = self.southeast:searchClosest(pos, bestPoint, bestDistance)
    end

    return bestPoint, bestDistance
end

-- Get all positions inside a given box
function QuadTree:queryRange(range, found)
    found = found or {}

    if range.xMax < self.xMin or range.xMin > self.xMax or range.yMax < self.yMin or range.yMin > self.yMax then
        return found -- No overlap
    end

    for _, point in ipairs(self.points) do
        if point.x >= range.xMin and point.x <= range.xMax and point.y >= range.yMin and point.y <= range.yMax then
            table.insert(found, point)
        end
    end

    if self.divided then
        self.northwest:queryRange(range, found)
        self.northeast:queryRange(range, found)
        self.southwest:queryRange(range, found)
        self.southeast:queryRange(range, found)
    end

    return found
end

-- Example usage
local quadTree = QuadTree.new(-4000, 4000, -4000, 4000)

quadTree:add({x = 100, y = 200})
quadTree:add({x = -300, y = -400})
quadTree:add({x = 1500, y = 2500})

local closest, distance = quadTree:searchClosest({x = 0, y = 0})
print("Closest point:", closest.x, closest.y, "Distance:", distance)

local pointsInRange = quadTree:queryRange({xMin = -500, xMax = 500, yMin = -500, yMax = 500})
for _, point in ipairs(pointsInRange) do
    print("Point in range:", point.x, point.y)
end