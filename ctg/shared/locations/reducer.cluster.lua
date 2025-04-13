-- [[ Helper functions: normalize_angle_deg, angle_diff_deg, average_angle_deg remain the same ]]
-- [[ Helper function: calculate_distance_2d_sq needs definition based on getDistanceBetweenPoints2D ]]
-- [[ Helper function: get_map_bounds remains the same ]]
-- [[ Assumes QuadTree implementation and setTimer ]]

-- Helper function provided by user, assuming it calculates squared distance
    function calculate_distance_2d_sq(p1, p2)
        -- Assuming getDistanceBetweenPoints2D returns the actual distance
        -- We need squared distance for efficiency
        local dist = getDistanceBetweenPoints2D(p1.x, p1.y, p2.x, p2.y)
        return dist * dist
        -- If getDistanceBetweenPoints2D *already* returns squared distance, just use:
        -- return getDistanceBetweenPoints2D(p1.x, p1.y, p2.x, p2.y)
    end
    
    
    ClusterReducer = {
        -- Configuration
        chunk_size = 500,    -- How many points to process per timer tick in loops
        timer_delay = 100,   -- Milliseconds between ticks (adjust as needed)
    
        -- State (managed internally)
        original_qt = nil,
        points = {},         -- Holds point objects with state (visited, cluster_id)
        clusters = {},       -- Stores points belonging to each cluster_id
        reduced_points = {}, -- Stores the final centroids and kept noise points
        current_index = 1,   -- Tracks progress through loops
        phase = 'idle',      -- 'idle', 'init', 'clustering', 'centroids', 'noise', 'finalizing', 'done'
        epsilon = 0,
        epsilon_sq = 0,
        minPts = 0,
        max_angle_diff_deg = 0,
        astar_distance = 0,
        astar_distance_sq = 0,
        callback = nil,      -- Final callback function
    
        -- Debugging/Stats
        core_points_found = 0,
        clusters_initiated = 0,
        noise_kept = 0
    }
    
    -- Make it behave like an object constructor
    function ClusterReducer:new(o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self
        -- Initialize state variables for a new instance
        o.points = {}
        o.clusters = {}
        o.reduced_points = {}
        o.current_index = 1
        o.phase = 'idle'
        o.core_points_found = 0
        o.clusters_initiated = 0
        o.noise_kept = 0
        return o
    end
    
    -- Main entry point to start the reduction process
    -- Note: Removed the outer callback list logic from user's original code
    -- This function now takes a single callback for completion.
    function ClusterReducer:reduceLocations(original_qt, callback, cluster_distance, min_cluster_points, max_rotation_diff, astar_distance)
        if self.phase ~= 'idle' and self.phase ~= 'done' then
            print("ClusterReducer: Warning - Reduction already in progress.")
            -- Optionally queue the request or return an error
            return
        end
    
        print("ClusterReducer: Initiating reduction...")
    
        -- Store parameters and state
        self.original_qt = original_qt
        self.callback = callback or function() print("ClusterReducer: Reduction finished (no callback provided).") end -- Ensure callback is callable
        self.epsilon = cluster_distance or 3.0
        self.epsilon_sq = self.epsilon * self.epsilon
        self.minPts = min_cluster_points or 3
        self.max_angle_diff_deg = max_rotation_diff or 90.0
        self.astar_distance = astar_distance or 7.0
        self.astar_distance_sq = self.astar_distance * self.astar_distance
    
        -- Reset state variables for a fresh run
        self.points = {}
        self.clusters = {}
        self.reduced_points = {}
        self.current_index = 1
        self.phase = 'init' -- Start with the initialization phase
        self.core_points_found = 0
        self.clusters_initiated = 0
        self.noise_kept = 0
    
        -- Schedule the first processing step using the timer
        -- Using an anonymous function ensures 'self' is correctly captured
        setTimer(function() self:_process_chunk() end, self.timer_delay, 1)
        print("ClusterReducer: Initial processing step scheduled.")
    end
    
    -- Internal function called by the timer to process a chunk
    function ClusterReducer:_process_chunk()
        -- Safety check in case timer fires unexpectedly
        if self.phase == 'idle' or self.phase == 'done' then
            print("ClusterReducer: Warning - _process_chunk called in inappropriate phase:", self.phase)
            return
        end
    
        print(string.format("ClusterReducer: Processing chunk, Phase: %s, Index: %d / %d",
                            self.phase, self.current_index, #self.points))
    
        -- Max execution time per chunk (optional, simple way to prevent long stalls)
        -- local start_time = os.clock()
        -- local max_duration = (self.timer_delay / 1000) * 0.8 -- Target 80% of timer delay
    
        -- ===================
        -- Phase Logic
        -- ===================
        if self.phase == 'init' then
            -- Phase 1: Prepare points from QuadTree
            print("ClusterReducer: Phase 'init'...")
            local all_points_refs = self.original_qt:getAll()
            self.points = {} -- Ensure it's clean
            -- We assume the objects from getAll() can have fields added directly.
            -- If not, we'd need to create copies.
            for i, p in ipairs(all_points_refs) do
                p.visited = false
                p.cluster_id = nil
                p.weak = true -- mark as weak initially
                -- Ensure points have a unique ID if not already present for neighbor lookup
                p.id = p.id or i -- Assign index as ID if 'id' doesn't exist
                table.insert(self.points, p)
            end
            print(string.format("ClusterReducer: Prepared %d points.", #self.points))
            self.phase = 'clustering'
            self.current_index = 1
    
        elseif self.phase == 'clustering' then
            -- Phase 2: Find clusters incrementally
            local points_processed_in_chunk = 0
            local end_index = math.min(self.current_index + self.chunk_size - 1, #self.points)
    
            for i = self.current_index, end_index do
                local point = self.points[i]
                if not point.visited then
                    point.visited = true
                    -- Query original QT - assumes it returns references to original objects
                    local found_neighbors_refs = self.original_qt:queryRadius(point, self.epsilon)
    
                    local valid_neighbors = {}
                    for _, neighbor_ref in ipairs(found_neighbors_refs) do
                         -- Find the point object in our self.points list that corresponds to the reference
                         -- This assumes neighbor_ref has a unique ID matching point.id
                         -- OR that neighbor_ref IS the object in self.points. Test this assumption!
                         local neighbor = self.points[neighbor_ref.id] -- Needs reliable ID mapping!
    
                         -- If the reference IS the object in self.points, this simplifies:
                         -- local neighbor = neighbor_ref
    
                         if neighbor and neighbor.id ~= point.id then -- Exclude self
                            if calculate_distance_2d_sq(point, neighbor) <= self.epsilon_sq then
                                if angle_diff_deg(point.rz, neighbor.rz) <= self.max_angle_diff_deg then
                                    table.insert(valid_neighbors, neighbor)
                                end
                            end
                         end
                    end
    
                    -- Include self in count for minPts check
                    if #valid_neighbors + 1 < self.minPts then
                        point.cluster_id = 'noise' -- Mark as noise for now
                    else
                        self.core_points_found = self.core_points_found + 1
                        self.clusters_initiated = self.clusters_initiated + 1
                        -- Call internal expand function. It accesses self.points, self.clusters etc.
                        self:_expand_cluster(point, valid_neighbors, self.clusters_initiated)
                        -- IMPORTANT: Assuming _expand_cluster is fast enough for one chunk.
                    end
                end
                points_processed_in_chunk = points_processed_in_chunk + 1
                -- Check execution time (optional)
                -- if os.clock() - start_time > max_duration then break end
            end
            self.current_index = self.current_index + points_processed_in_chunk
    
            -- Check if phase is complete
            if self.current_index > #self.points then
                print(string.format("ClusterReducer: Clustering phase complete. Found %d core points, initiated %d clusters.", self.core_points_found, self.clusters_initiated))
                self.phase = 'centroids'
                self.current_index = 1 -- Reset index for next phase
            end
    
        elseif self.phase == 'centroids' then
            -- Phase 3: Calculate all centroids
            -- Assuming this is fast enough for one chunk. If not, needs chunking too.
            print("ClusterReducer: Phase 'centroids'...")
            self.reduced_points = {} -- Clear previous results if any
            for c_id, point_list in pairs(self.clusters) do
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
                    local centroid = {
                        x = sum_x / count, y = sum_y / count, z = sum_z / count,
                        rx = 0, ry = 0, rz = avg_rz, -- Assuming rx, ry not averaged
                        cluster_id = c_id, -- Keep track of source cluster if needed
                        weak = true -- Initially weak, finalized later
                    }
                    table.insert(self.reduced_points, centroid)
                end
            end
            print(string.format("ClusterReducer: Generated %d centroids.", #self.reduced_points))
            self.phase = 'noise'
            self.current_index = 1 -- Reset index for noise handling phase
    
        elseif self.phase == 'noise' then
            -- Phase 4: Handle noise points incrementally
            local points_processed_in_chunk = 0
            local end_index = math.min(self.current_index + self.chunk_size - 1, #self.points)
            local temp_noise_to_keep = {} -- Collect noise points locally for this chunk
    
            for i = self.current_index, end_index do
                local point = self.points[i]
                if point.cluster_id == 'noise' then
                    local is_close_to_centroid = false
                    for _, centroid in ipairs(self.reduced_points) do
                        -- Check distance against epsilon. Using epsilon keeps noise points
                        -- further away than the clustering distance itself.
                        if calculate_distance_2d_sq(point, centroid) <= self.epsilon_sq then
                            is_close_to_centroid = true
                            break
                        end
                    end
                    if not is_close_to_centroid then
                        -- Prepare to keep the original noise point
                        local keep_noise = {x=point.x, y=point.y, z=point.z, rx=point.rx, ry=point.ry, rz=point.rz, weak = true, cluster_id = 'noise'}
                        table.insert(temp_noise_to_keep, keep_noise)
                        self.noise_kept = self.noise_kept + 1 -- Count total kept noise
                    end
                end
                points_processed_in_chunk = points_processed_in_chunk + 1
                 -- Optional time check
            end
            -- Add collected noise points from this chunk to the main list
            for _, noise_point in ipairs(temp_noise_to_keep) do
                 table.insert(self.reduced_points, noise_point)
            end
    
            self.current_index = self.current_index + points_processed_in_chunk
    
            -- Check if phase complete
            if self.current_index > #self.points then
                print(string.format("ClusterReducer: Noise handling phase complete. Total kept noise points: %d.", self.noise_kept))
                self.phase = 'finalizing'
                self.current_index = 1 -- Reset index for finalization phase
            end
    
        elseif self.phase == 'finalizing' then
            -- Phase 5: Mark final points as not weak incrementally
            local points_processed_in_chunk = 0
            local end_index = math.min(self.current_index + self.chunk_size - 1, #self.reduced_points)
    
            for i = self.current_index, end_index do
                self.reduced_points[i].weak = false
                points_processed_in_chunk = points_processed_in_chunk + 1
                -- Optional time check
            end
            self.current_index = self.current_index + points_processed_in_chunk
    
            -- Check if phase complete
            if self.current_index > #self.reduced_points then
                print("ClusterReducer: Finalizing phase complete.")
                self.phase = 'done'
            end
    
        end -- End of phase logic
    
        -- ===================
        -- Scheduling / Completion
        -- ===================
        if self.phase ~= 'done' and self.phase ~= 'idle' then
            -- Schedule the next chunk
            setTimer(function() self:_process_chunk() end, self.timer_delay, 1)
        elseif self.phase == 'done' then
            -- Process finished!
            print(string.format("ClusterReducer: Reduction complete. Final point count: %d", #self.reduced_points))
            -- Clear temporary data (optional, depends if reducer instance is reused)
            -- self.points = {}
            -- self.clusters = {}
            -- Call the final callback
            if self.callback then
                 -- Pass a clean copy of the results if the reducer might modify them later
                local final_result_copy = {}
                for _, p in ipairs(self.reduced_points) do table.insert(final_result_copy, p) end
                self.callback(final_result_copy)
            end
            self.phase = 'idle' -- Mark as ready for a potential new task
        end
    end
    
    
    -- Internal helper function to expand clusters (accesses self.points, self.clusters)
    -- Runs synchronously within one _process_chunk call. Assumed fast enough.
    function ClusterReducer:_expand_cluster(seed_point, initial_neighbors, cluster_id)
        self.clusters[cluster_id] = self.clusters[cluster_id] or {}
        table.insert(self.clusters[cluster_id], seed_point)
        seed_point.cluster_id = cluster_id
    
        local queue = {}
        for _, neighbor in ipairs(initial_neighbors) do
            -- Use neighbor's unique ID as the key in the queue table
            if not neighbor.visited or neighbor.cluster_id == 'noise' then
                 queue[neighbor.id] = neighbor
            end
        end
    
        while next(queue) ~= nil do
            local current_neighbor_id, current_neighbor = next(queue)
            queue[current_neighbor_id] = nil -- Remove from queue by key
    
            -- Check if it's truly unassigned or was just noise
            if current_neighbor.cluster_id ~= cluster_id then
                 -- If it was noise, claim it for this cluster
                 if current_neighbor.cluster_id == 'noise' then
                     current_neighbor.cluster_id = cluster_id
                     table.insert(self.clusters[cluster_id], current_neighbor)
                     -- Don't mark visited here, let the main check below handle it
                 end
    
                 -- Process if it hasn't been visited (assigned to a cluster) yet
                 if not current_neighbor.visited then
                     current_neighbor.visited = true
                     current_neighbor.cluster_id = cluster_id -- Assign cluster ID
                     table.insert(self.clusters[cluster_id], current_neighbor) -- Add to point list for this cluster
    
                     -- Find *its* neighbors from original QT
                     local found_new_refs = self.original_qt:queryRadius(current_neighbor, self.epsilon)
                     local valid_new_neighbors = {}
                     for _, potential_neighbor_ref in ipairs(found_new_refs) do
                         -- Find the corresponding stateful point object
                         local potential_neighbor = self.points[potential_neighbor_ref.id] -- Requires ID mapping
                         if potential_neighbor then
                             if calculate_distance_2d_sq(current_neighbor, potential_neighbor) <= self.epsilon_sq then
                                 if angle_diff_deg(current_neighbor.rz, potential_neighbor.rz) <= self.max_angle_diff_deg then
                                    table.insert(valid_new_neighbors, potential_neighbor)
                                 end
                             end
                         end
                     end
    
                     -- Check if this neighbor is also a core point (using +1 for self)
                     if #valid_new_neighbors + 1 >= self.minPts then
                         -- If it's a core point, add its valid neighbors to the queue
                         for _, new_potential in ipairs(valid_new_neighbors) do
                             -- Add only if not visited/assigned and not already in queue
                             if (not new_potential.visited or new_potential.cluster_id == 'noise') and not queue[new_potential.id] then
                                 queue[new_potential.id] = new_potential
                             end
                         end
                     end
                end -- end if not visited
            end -- end if cluster_id mismatch
        end -- end while queue not empty
    end
    
    
    -- ##### Example Usage #####
    
    -- Assume QuadTree class exists and is populated
    -- local my_quad_tree = QuadTree.new(-3500, 3500, -3500, 3500, 4) -- Example bounds/capacity
    -- local all_game_points = { ... } -- Your point data
    -- -- Populate my_quad_tree with points...
    -- for i, p in ipairs(all_game_points) do
    --      p.id = i -- Assign a unique ID (index is simple if list doesn't change)
    --      my_quad_tree:add(p)
    -- end
    
    
    -- Create a reducer instance
    local reducer = ClusterReducer:new({
        chunk_size = 1000, -- Process 1000 points per tick in loops
        timer_delay = 50   -- Wait 50ms between ticks
    })
    
    -- Define parameters
    local cluster_distance = 8.0
    local min_cluster_points = 3
    local max_rotation_diff = 90.0
    local astar_distance = 7.0
    
    -- Define the callback function for when reduction is complete
    local function on_reduction_complete(final_reduced_points)
        print("--- Reduction Complete ---")
        print("Received", #final_reduced_points, "reduced points.")
        -- Do something with the final points: save, update game state, etc.
        -- [[ Add your logic here ]]
    
        -- Example: Print some results
        -- for i = 1, math.min(10, #final_reduced_points) do
        --     local p = final_reduced_points[i]
        --     print(string.format("Point %d: x=%.2f, y=%.2f, z=%.2f, rz=%.2f (Weak: %s, Cluster: %s)",
        --                         i, p.x, p.y, p.z, p.rz, tostring(p.weak), tostring(p.cluster_id or 'noise')))
        -- end
    end
    
    -- Start the reduction process (ensure my_quad_tree is populated first!)
    -- reducer:reduceLocations(
    --     my_quad_tree,
    --     on_reduction_complete,
    --     cluster_distance,
    --     min_cluster_points,
    --     max_rotation_diff,
    --     astar_distance
    -- )
    
    -- print("Cluster reduction process started asynchronously...")