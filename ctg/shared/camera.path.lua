--[[
  Creates a smooth camera fly-through along a recorded path.

  Args:
    recordedPoints (table): A list of points {x, y, z}. Must contain at least 2 points.
    playerToShowTheCameraFor (player): The player element the camera belongs to.
    cameraFlySpeed (number): A value controlling speed. Higher means faster. Adjust based on desired feel.
                             A value around 0.5 to 2 might be a good starting point depending on timer interval.
]]
local currentFlyTimer = nil -- Variable to hold the active timer

function cameraFly(recordedPoints, playerToShowTheCameraFor, cameraFlySpeed)
  -- Stop any previous fly-through
  if isTimer(currentFlyTimer) then
    killTimer(currentFlyTimer)
    currentFlyTimer = nil
  end

  -- Validate input
  if not recordedPoints or #recordedPoints < 2 then
    print("Error: cameraFly requires at least 2 recorded points.")
    -- Optional: Reset camera to a default state here if needed
    -- setCameraTarget(playerToShowTheCameraFor) -- Example reset
    return
  end

  if not isElement(playerToShowTheCameraFor) then
     print("Error: cameraFly requires a valid player element.")
     return
  end

  -- Animation state variables
  local currentSegment = 1 -- Start at the first segment (between point 1 and 2)
  local t = 0.0          -- Interpolation factor within the current segment
  local numPoints = #recordedPoints
  local numSegments = numPoints - 1

  -- Constants for the animation loop
  local timerInterval = 50 -- ms between updates (adjust for smoother/less smooth, affects performance)
  local lookAheadFactor = 0.05 -- How far ahead on the spline to look (0.0 to 1.0). Small values give smoother look direction.

  -- --- The Timer Callback Function ---
  local function updateCameraFly()
    -- Calculate the four points needed for Catmull-Rom for the current segment
    -- Handle edge cases for the start and end of the path
    local p0, p1, p2, p3

    -- Point p1 is the start of the current segment (index currentSegment)
    p1 = recordedPoints[currentSegment]
    -- Point p2 is the end of the current segment (index currentSegment + 1)
    p2 = recordedPoints[currentSegment + 1]

    -- Point p0 (point before p1)
    if currentSegment == 1 then
      p0 = p1 -- Duplicate start point if at the very beginning
    else
      p0 = recordedPoints[currentSegment - 1]
    end

    -- Point p3 (point after p2)
    if currentSegment >= numSegments then
      p3 = p2 -- Duplicate end point if at the very end
    else
      p3 = recordedPoints[currentSegment + 2]
    end

    -- Calculate camera position using Catmull-Rom
    local camPos = catmullRomInterpolate(p0, p1, p2, p3, t)

    -- Calculate look-at position: slightly ahead on the same spline segment
    local lookAtT = math.min(t + lookAheadFactor, 1.0) -- Calculate T for look-at, clamp to 1.0
    local lookAtPos = catmullRomInterpolate(p0, p1, p2, p3, lookAtT)

    -- Ensure lookAtPos is not identical to camPos (can happen at segment ends or with zero lookAheadFactor)
    if camPos.x == lookAtPos.x and camPos.y == lookAtPos.y and camPos.z == lookAtPos.z then
        -- If they are the same, try looking at the actual end point of the segment (p2)
        -- If that's *also* the same, look slightly ahead towards p3 (if available)
        if camPos.x == p2.x and camPos.y == p2.y and camPos.z == p2.z then
            if currentSegment < numSegments then -- Check if p3 is valid
                lookAtPos = recordedPoints[currentSegment + 2]
            else
                 -- Very last resort: Add a small offset in a default direction (e.g., forward)
                 -- This depends on your game's coordinate system. Assuming +X is forward:
                 lookAtPos = { x = camPos.x + 0.1, y = camPos.y, z = camPos.z }
            end
        else
             lookAtPos = p2
        fi
    end


    -- Set the camera matrix
    setCameraMatrix(playerToShowTheCameraFor,
                    camPos.x, camPos.y, camPos.z,
                    lookAtPos.x, lookAtPos.y, lookAtPos.z)

    -- Update interpolation factor 't' for the next frame
    -- This simple approach makes speed vary slightly based on segment length.
    -- For constant speed, you'd need to estimate segment arc length, which is more complex.
    local segmentLengthApprox = vecLength(vecSubtract(p2, p1)) -- Straight line distance
    local deltaT = 0 -- Default to 0 to avoid division by zero

    if segmentLengthApprox > 0.001 then -- Avoid division by zero or tiny segments
        -- Adjust speed based on interval and desired speed factor
        -- The division by segmentLengthApprox tries to normalize speed across segments
         deltaT = (cameraFlySpeed * (timerInterval / 1000)) / segmentLengthApprox
    else
        -- If segment is tiny, just jump to the end of it in the next frame
        deltaT = 1.0
    end


    t = t + deltaT

    -- Move to the next segment if 't' exceeds 1.0
    if t >= 1.0 then
      currentSegment = currentSegment + 1
      t = 0.0 -- Reset t for the new segment

      -- Check if we finished the whole path
      if currentSegment > numSegments then
        print("Camera fly-through finished.")
        if isTimer(currentFlyTimer) then
          killTimer(currentFlyTimer)
          currentFlyTimer = nil
        end
        -- Optional: Snap camera to the very last point precisely
         setCameraMatrix(playerToShowTheCameraFor,
                    recordedPoints[numPoints].x, recordedPoints[numPoints].y, recordedPoints[numPoints].z,
                    lookAtPos.x, lookAtPos.y, lookAtPos.z) -- Keep last lookAt or recalculate if needed

        -- Optional: Restore default camera control to the player
        -- setCameraTarget(playerToShowTheCameraFor)
        return -- Stop the update loop
      end
    end
  end

  -- Start the timer
  -- The '0' means execute indefinitely (until killed)
  print("Starting camera fly-through...")
  currentFlyTimer = setTimer(updateCameraFly, timerInterval, 0)

  -- Initial camera setup (optional, but good practice)
  -- Position camera at the very start point, looking towards the second point
  local startPos = recordedPoints[1]
  local nextPos = recordedPoints[2]
    setCameraMatrix(playerToShowTheCameraFor,
                    startPos.x, startPos.y, startPos.z,
                    nextPos.x, nextPos.y, nextPos.z)


end