-- [[ Previous helper functions like calculate_distance_2d_sq, get_map_bounds remain ]]
-- [[ Assumes QuadTree implementation ]]

ClusterReducer = {
    callbacks = {},
    neighborsRadius = 10,
    totalToMarkAtTime = 500,
}

function ClusterReducer:addCallback(callback)
    table.insert(self.callbacks, callback)
end

function ClusterReducer:callCallbacks()
    for i, callback in ipairs(self.callbacks) do
        callback()
    end
    self.callbacks = {}
end

function ClusterReducer:reduceLocations(original_qt, callback, cluster_distance, min_cluster_points, max_rotation_diff, astar_distance)
    self:addCallback(callback)
    setTimer(function ()
        local cluster_distance = cluster_distance or 3.0 -- Max distance for neighbors (epsilon)
        local min_cluster_points = min_cluster_points or 3 -- Min points to form a dense cluster
        local max_rotation_diff = max_rotation_diff or 90.0 -- Max angle diff in degrees
        local astar_distance = astar_distance or 7.0 -- A* connection distance (used for noise check logic maybe)

        local reducedLocations = reduce_points_clustered(original_qt, cluster_distance, min_cluster_points, max_rotation_diff, astar_distance)
        self:callCallbacks(reducedLocations)
    end, 1000, 1)
end

function calculate_distance_2d_sq(p1, p2)
    return getDistanceBetweenPoints2D(p1.x, p1.y, p2.x, p2.y)
end

-- Helper function for angle normalization (to -180 to 180)
local function normalize_angle_deg(angle)
    angle = angle % 360
    if angle > 180 then
        angle = angle - 360
    elseif angle <= -180 then
        angle = angle + 360
    end
    return angle
end
    
    -- Helper function for angle difference (degrees)
local function angle_diff_deg(a1, a2)
    local diff = normalize_angle_deg(a1) - normalize_angle_deg(a2)
    return math.abs(normalize_angle_deg(diff)) -- Ensure result is positive diff <= 180
    end
    
    -- Helper function to calculate average angle (rz) - robust method using vectors
    local function average_angle_deg(angles_deg)
    local count = #angles_deg
    if count == 0 then return 0 end -- Or handle error/default
    
    local sum_x, sum_y = 0, 0
    for _, angle_deg in ipairs(angles_deg) do
        local rad = math.rad(angle_deg)
        sum_x = sum_x + math.cos(rad)
        sum_y = sum_y + math.sin(rad)
    end
    
    local avg_rad = math.atan2(sum_y / count, sum_x / count)
    return math.deg(avg_rad)
end

function get_map_bounds(points)
    local xMin, xMax = math.huge, -math.huge
    local yMin, yMax = math.huge, -math.huge
    for _, p in ipairs(points) do
        if p.x < xMin then xMin = p.x end
        if p.x > xMax then xMax = p.x end
        if p.y < yMin then yMin = p.y end
        if p.y > yMax then yMax = p.y end
    end
    return xMin, xMax, yMin, yMax
end
    
    -- Modified main reduction function
function reduce_points_clustered(original_qt, epsilon, minPts, max_angle_diff_deg, astar_connect_dist)
    if not original_qt then return {} end
    local points = original_qt:getAll()
    
    print(string.format("Starting clustered reduction. Points: %d, Epsilon: %.2f, MinPts: %d, MaxAngleDiff: %.1f",
                        #points, epsilon, minPts, max_angle_diff_deg))
    
    -- 1. Prepare points and QuadTree
    for i, p in ipairs(points) do
        p.visited = false
        p.cluster_id = nil
        p.weak = true -- mark as weak and then mark all reduced point as not weak in the end
    end
    
    local epsilon_sq = epsilon * epsilon -- Use squared distance
    
    local clusters = {}
    local current_cluster_id = 0
    
    -- Expand Cluster function (defined inside or outside main func)
    local function expand_cluster(seed_point, initial_neighbors, cluster_id)
        clusters[cluster_id] = clusters[cluster_id] or {}
        table.insert(clusters[cluster_id], seed_point)
        seed_point.cluster_id = cluster_id
    
        local queue = {}
        for _, neighbor in ipairs(initial_neighbors) do
            -- Add neighbor to queue only if it makes sense to process it
            if not neighbor.visited or neighbor.cluster_id == 'noise' then
                queue[neighbor.id] = neighbor -- Use id as key to avoid duplicates in queue logic
            end
        end
    
        while next(queue) ~= nil do
            -- Get next point from queue (basic table iteration works as pop substitute here)
            local current_neighbor_id, current_neighbor = next(queue)
            queue[current_neighbor_id] = nil -- Remove from queue
    
            -- Process if not already assigned to this or another cluster
            if current_neighbor.cluster_id ~= cluster_id then
                if current_neighbor.cluster_id == 'noise' then
                    current_neighbor.cluster_id = cluster_id -- Claim noise point
                    table.insert(clusters[cluster_id], current_neighbor)
                end
    
                if not current_neighbor.visited then
                    current_neighbor.visited = true
                    current_neighbor.cluster_id = cluster_id -- Assign cluster
                    table.insert(clusters[cluster_id], current_neighbor) -- Add to cluster list
    
                    -- Find *its* neighbors
                    local found_new = original_qt:queryRadius(current_neighbor, epsilon)
                    local valid_new_neighbors = {}
                    for _, potential_neighbor in ipairs(found_new) do
                        -- Check distance (redundant if queryRadius is exact, good check otherwise)
                        if calculate_distance_2d_sq(current_neighbor, potential_neighbor) <= epsilon_sq then
                            -- Check rotation
                            if angle_diff_deg(current_neighbor.rz, potential_neighbor.rz) <= max_angle_diff_deg then
                                table.insert(valid_new_neighbors, potential_neighbor)
                            end
                        end
                    end
    
                    -- If it's also a core point, expand from its neighbors
                    if #valid_new_neighbors >= minPts then
                        for _, new_potential in ipairs(valid_new_neighbors) do
                            if not new_potential.visited or new_potential.cluster_id == 'noise' then
                                queue[new_potential.id] = new_potential -- Add eligible neighbors to queue
                            end
                        end
                    end
                end
            end
        end
    end -- end of expand_cluster function
    
    -- 3. Cluster Finding Loop
    print("Finding clusters...")
    local core_points_found = 0
    for i, point in ipairs(points) do
        if not point.visited then
            point.visited = true
            local found_neighbors = original_qt:queryRadius(point, epsilon)
    
            local valid_neighbors = {}
            for _, neighbor in ipairs(found_neighbors) do
                    if neighbor.id ~= point.id then -- Exclude self
                    if calculate_distance_2d_sq(point, neighbor) <= epsilon_sq then
                        if angle_diff_deg(point.rz, neighbor.rz) <= max_angle_diff_deg then
                            table.insert(valid_neighbors, neighbor)
                        end
                    end
                    end
            end
    
            -- Include self in count for minPts check
            if #valid_neighbors + 1 < minPts then
                point.cluster_id = 'noise' -- Mark as noise for now
            else
                core_points_found = core_points_found + 1
                current_cluster_id = current_cluster_id + 1
                expand_cluster(point, valid_neighbors, current_cluster_id)
            end
        end
    end
    print(string.format("Found %d core points, initiating %d clusters.", core_points_found, current_cluster_id))
    
    -- 5. Calculate Centroids
    print("Calculating centroids...")
    local reduced_points = {}
    for c_id, point_list in pairs(clusters) do
        local count = #point_list
        if count > 0 then
            local sum_x, sum_y, sum_z = 0, 0, 0
            local angles = {}
            for _, p in ipairs(point_list) do
                sum_x = sum_x + p.x
                sum_y = sum_y + p.y
                sum_z = sum_z + p.z
                table.insert(angles, p.rz)
            end
            local avg_rz = average_angle_deg(angles)
            -- Assuming rx, ry aren't averaged, default to 0 or copy from one point?
            local centroid = {
                x = sum_x / count, y = sum_y / count, z = sum_z / count,
                rx = 0, ry = 0, rz = avg_rz,
                cluster_id = c_id -- Keep track of source cluster if needed
            }
            table.insert(reduced_points, centroid)
        end
    end
    print(string.format("Generated %d centroids.", #reduced_points))
    
    -- 6. Handle Noise Points
    print("Handling noise points...")
    local noise_kept = 0
    local astar_connect_dist_sq = astar_connect_dist * astar_connect_dist
    for _, point in ipairs(points) do
        if point.cluster_id == 'noise' then
            local is_close_to_centroid = false
            for _, centroid in ipairs(reduced_points) do
                if calculate_distance_2d_sq(point, centroid) <= epsilon_sq then -- Use epsilon or astar dist? Epsilon seems reasonable
                    is_close_to_centroid = true
                    break
                end
            end
            if not is_close_to_centroid then
                -- Keep the original noise point, remove temporary fields
                local keep_noise = {x=point.x, y=point.y, z=point.z, rx=point.rx, ry=point.ry, rz=point.rz}
                table.insert(reduced_points, keep_noise)
                noise_kept = noise_kept + 1
            end
        end
    end
    print(string.format("Kept %d noise points.", noise_kept))

    for _, point in ipairs(reduced_points) do
        point.weak = false
    end    
    
    print(string.format("Final reduced point count: %d", #reduced_points))
    return reduced_points
end
    
    
-- ##### Example Usage #####

-- [[ Load your all_game_points table as before ]]
local all_game_points = {
    -- More complex example needed to show clustering
    -- Road segment 1 (moving +X)
    {x=10, y=10, z=0, rx=0, ry=0, rz=0},
    {x=14, y=10.5, z=0, rx=0, ry=0, rz=1},
    {x=18, y=10, z=0, rx=0, ry=0, rz=-1},
    {x=22, y=10.5, z=0, rx=0, ry=0, rz=0},
    -- Road segment 2 (moving +Y, slightly offset) - should be separate cluster if angle diff > 90
    {x=23, y=20, z=0, rx=0, ry=0, rz=90},
    {x=22.5, y=25, z=0, rx=0, ry=0, rz=91},
    {x=23.5, y=30, z=0, rx=0, ry=0, rz=89},
    -- Opposite direction on road 1
    {x=20, y=12, z=0, rx=0, ry=0, rz=180},
    {x=15, y=11.5, z=0, rx=0, ry=0, rz=179},
    {x=11, y=12, z=0, rx=0, ry=0, rz=-178},
    -- A sparse point
    {x=50, y=50, z=0, rx=0, ry=0, rz=45}
}

-- Define parameters
local cluster_distance = 8.0 -- Max distance for neighbors (epsilon)
local min_cluster_points = 3 -- Min points to form a dense cluster
local max_rotation_diff = 90.0 -- Max angle diff in degrees
local astar_distance = 7.0 -- A* connection distance (used for noise check logic maybe)

local original_qt = QuadTree.new(-3500, 3500, -3500, 3500)

-- Run the reduction
local reduced_game_points = reduce_points_clustered(
    original_qt,
    cluster_distance,
    min_cluster_points,
    max_rotation_diff,
    astar_distance
)

-- [[ Save reduced_game_points as before ]]

-- Optional: Print results
print("--- Reduced Points (Clustered) ---")
for i, p in ipairs(reduced_game_points) do
print(string.format("Point %d: x=%.2f, y=%.2f, z=%.2f, rz=%.2f (Cluster: %s)",
                    i, p.x, p.y, p.z, p.rz, tostring(p.cluster_id or 'noise'))) -- Show cluster ID if kept
end