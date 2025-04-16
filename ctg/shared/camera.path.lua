--[[
=================================================================================
 Camera Fly-Through System with Catmull-Rom Splines and Smoothing
=================================================================================

 Creates a smooth camera animation ("fly-through") along a given path of points.
 Features:
   - Uses Catmull-Rom splines to interpolate through recorded points.
   - Optional look-at smoothing (damping) for softer camera rotation.
   - Callback function invoked upon completion or cancellation.
   - Function to cancel the animation prematurely.

 Functions:
   - cameraFly(recordedPoints, player, speed, onCompleteCallback, options)
   - cancelCameraFly()

 Dependencies:
   - Assumes access to a `setCameraMatrix(posX, posY, posZ, lookAtX, lookAtY, lookAtZ)` function.
   - Assumes access to timer functions `setTimer(func, interval, times)` and `killTimer(timer)`.
   - Assumes `isTimer(timer)` and `isElement(player)` checks exist.
   - Uses `pcall` for safe callback execution.

=================================================================================
--]]

-- =============================================================================
-- Helper Functions (Vector Math & Interpolation)
-- =============================================================================

local function vecLength(v)
  if not v then return 0 end
  return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
end

local function vecSubtract(v1, v2)
  if not v1 or not v2 then return { x = 0, y = 0, z = 0 } end
  return { x = v1.x - v2.x, y = v1.y - v2.y, z = v1.z - v2.z }
end

local function vecAdd(v1, v2)
    if not v1 or not v2 then return { x = 0, y = 0, z = 0 } end
    return { x = v1.x + v2.x, y = v1.y + v2.y, z = v1.z + v2.z }
end

local function vecScale(v, scalar)
  if not v then return { x = 0, y = 0, z = 0 } end
  return { x = v.x * scalar, y = v.y * scalar, z = v.z * scalar }
end

-- Linear interpolation between two vectors
local function vecLerp(v1, v2, factor)
  if not v1 or not v2 then return { x = 0, y = 0, z = 0 } end
  factor = math.max(0.0, math.min(1.0, factor)) -- Clamp factor between 0 and 1
  return {
    x = v1.x + (v2.x - v1.x) * factor,
    y = v1.y + (v2.y - v1.y) * factor,
    z = v1.z + (v2.z - v1.z) * factor
  }
end

-- Catmull-Rom Spline Interpolation
-- p0, p1, p2, p3 are points {x, y, z}
-- t is the interpolation factor (0.0 to 1.0) between p1 and p2
local function catmullRomInterpolate(p0, p1, p2, p3, t)
  -- Ensure points are valid tables, provide defaults if not (avoids errors)
  p0 = p0 or {x=0,y=0,z=0}
  p1 = p1 or {x=0,y=0,z=0}
  p2 = p2 or {x=0,y=0,z=0}
  p3 = p3 or {x=0,y=0,z=0}

  local t2 = t * t
  local t3 = t2 * t

  local out = {}
  out.x = 0.5 * ( (2 * p1.x) +
                  (-p0.x + p2.x) * t +
                  (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * t2 +
                  (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * t3 )
  out.y = 0.5 * ( (2 * p1.y) +
                  (-p0.y + p2.y) * t +
                  (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t2 +
                  (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t3 )
  out.z = 0.5 * ( (2 * p1.z) +
                  (-p0.z + p2.z) * t +
                  (2 * p0.z - 5 * p1.z + 4 * p2.z - p3.z) * t2 +
                  (-p0.z + 3 * p1.z - 3 * p2.z + p3.z) * t3 )
  return out
end

-- =============================================================================
-- Global State for Active Animation
-- =============================================================================

-- Holds the state of the currently active camera fly animation
local activeFlyAnimation = {
    timer = nil,
    callback = nil
}

-- =============================================================================
-- Camera Fly Function
-- =============================================================================

--[[
  Creates a smooth camera fly-through along a recorded path.

  Args:
    recordedPoints (table): A list of points {x, y, z}. Must contain at least 2 points.
    playerToShowTheCameraFor (player): The player element the camera belongs to.
    cameraFlySpeed (number): A value controlling speed along the path. Higher is faster.
    onCompleteCallback (function, optional): A function to call when the fly-through finishes or is cancelled.
    options (table, optional): A table for additional settings:
      options.lookAtSmoothFactor (number): Controls look-at smoothing (0.01 to 1.0). Lower values = smoother. Default: 0.1.
]]
function cameraFly(recordedPoints, playerToShowTheCameraFor, cameraFlySpeed, onCompleteCallback, options)

  -- --- Stop and potentially call callback for any PREVIOUS fly-through ---
  if activeFlyAnimation.timer and isTimer(activeFlyAnimation.timer) then
    print("Cancelling previous camera fly due to new request.")
    local previousCallback = activeFlyAnimation.callback -- Get callback before clearing
    killTimer(activeFlyAnimation.timer)
    activeFlyAnimation.timer = nil
    activeFlyAnimation.callback = nil
    if type(previousCallback) == "function" then
      pcall(previousCallback) -- Safely call the previous callback
    end
  end
  -- Clear any lingering state just in case
  activeFlyAnimation.timer = nil
  activeFlyAnimation.callback = nil

  -- --- Input Validation ---
  if not recordedPoints or type(recordedPoints) ~= "table" or #recordedPoints < 2 then
    print("Error: cameraFly requires a table with at least 2 recorded points.")
    if type(onCompleteCallback) == "function" then pcall(onCompleteCallback) end
    return
  end
  if not isElement(playerToShowTheCameraFor) then
     print("Error: cameraFly requires a valid player element.")
     if type(onCompleteCallback) == "function" then pcall(onCompleteCallback) end
     return
  end
   if onCompleteCallback and type(onCompleteCallback) ~= "function" then
      print("Warning: cameraFly received a non-function value for onCompleteCallback.")
      onCompleteCallback = nil -- Ignore non-function callbacks
   end

  -- --- Options and State Setup ---
  options = options or {}
  local lookAtSmoothFactor = options.lookAtSmoothFactor or 0.1
  lookAtSmoothFactor = math.max(0.01, math.min(1.0, lookAtSmoothFactor)) -- Clamp factor

  local currentSegment = 1 -- Current segment index (1-based)
  local t = 0.0            -- Interpolation factor (0.0 to 1.0) within the segment
  local numPoints = #recordedPoints
  local numSegments = numPoints - 1
  local timerInterval = 50 -- Milliseconds between updates
  local lookAheadFactor = 0.05 -- How far ahead (in t) to calculate the target look-at point

  -- State for smoothing within this specific animation's closure
  local currentActualLookAt = nil


  -- --- Timer Callback Function (Closure) ---
  local function updateCameraFly()
    -- Check if the timer associated with *this* fly animation is still the active one.
    if not activeFlyAnimation.timer or not isTimer(activeFlyAnimation.timer) then
        -- print("DEBUG: Stale timer execution prevented.") -- Optional debug msg
        return
    end

    -- Calculate control points (p0, p1, p2, p3) for Catmull-Rom
    local p0, p1, p2, p3
    p1 = recordedPoints[currentSegment]
    p2 = recordedPoints[currentSegment + 1]

    -- Handle edge cases for p0 and p3
    if currentSegment == 1 then
      p0 = p1 -- Duplicate start point
    else
      p0 = recordedPoints[currentSegment - 1]
    end

    if currentSegment >= numSegments then
      p3 = p2 -- Duplicate end point
    else
      -- Ensure p3 exists, safety check for paths with exactly 2 points
      p3 = recordedPoints[currentSegment + 2] or p2
    end

    -- Calculate TARGET camera position on the spline
    local targetCamPos = catmullRomInterpolate(p0, p1, p2, p3, t)

    -- Calculate TARGET look-at position (slightly ahead on spline)
    local lookAtT = math.min(t + lookAheadFactor, 1.0)
    local targetLookAtPos = catmullRomInterpolate(p0, p1, p2, p3, lookAtT)

    -- Handle edge case: Avoid looking at own position
    if vecLength(vecSubtract(targetCamPos, targetLookAtPos)) < 0.01 then
      -- Try looking at the segment end point (p2)
      if vecLength(vecSubtract(targetCamPos, p2)) < 0.01 then
          -- If still too close, look at the point after p2 (p3), if available
          if currentSegment < numSegments and recordedPoints[currentSegment + 2] then
              targetLookAtPos = recordedPoints[currentSegment + 2]
          else
               -- Last resort: look slightly ahead in a default direction (e.g., positive X)
               targetLookAtPos = { x = targetCamPos.x + 0.1, y = targetCamPos.y, z = targetCamPos.z }
          end
      else
           targetLookAtPos = p2
      end
    end

    -- Initialize or Smooth the ACTUAL Look-At Position using Lerp
    if not currentActualLookAt then
      currentActualLookAt = targetLookAtPos -- Initialize on first run
    else
      currentActualLookAt = vecLerp(currentActualLookAt, targetLookAtPos, lookAtSmoothFactor)
    end

    -- Set the actual camera matrix
    setCameraMatrix(targetCamPos.x, targetCamPos.y, targetCamPos.z,
                    currentActualLookAt.x, currentActualLookAt.y, currentActualLookAt.z)

    -- Update interpolation factor 't' based on speed and approximate segment length
    local segmentLengthApprox = vecLength(vecSubtract(p2, p1))
    local deltaT = 0
    if segmentLengthApprox > 0.001 then
        -- Adjust speed based on interval and desired speed factor, normalized by approx length
         deltaT = (cameraFlySpeed * (timerInterval / 1000)) / segmentLengthApprox
    else
        -- If segment is tiny, just jump to the end of it in the next frame
        deltaT = 1.0
    end
    t = t + deltaT

    -- Move to the next segment if 't' exceeds 1.0
    if t >= 1.0 then
      currentSegment = currentSegment + 1
      t = t - 1.0 -- Carry over the remainder of t for smoother speed across segments (optional)
      -- t = 0.0 -- Simpler alternative: Reset t completely

      -- --- Check for Completion ---
      if currentSegment > numSegments then
        print("Camera fly-through finished.")
        local callbackToCall = activeFlyAnimation.callback -- Get callback before clearing state

        -- Clean up global state
        if activeFlyAnimation.timer and isTimer(activeFlyAnimation.timer) then killTimer(activeFlyAnimation.timer) end
        activeFlyAnimation.timer = nil
        activeFlyAnimation.callback = nil
        currentActualLookAt = nil -- Clear local state too

        -- Optional: Final snap to the exact end position
        local finalPos = recordedPoints[numPoints]
        -- Use the very last calculated target lookAt for the final frame
        setCameraMatrix(finalPos.x, finalPos.y, finalPos.z,
                        targetLookAtPos.x, targetLookAtPos.y, targetLookAtPos.z)

        -- Call the completion callback if it exists
        if type(callbackToCall) == "function" then
            pcall(callbackToCall) -- Use pcall for safety
        end
        return -- Stop the update loop
      end
    end
  end

  -- --- Start the Timer ---
  print("Starting camera fly-through...")
  -- Initialize the look-at state before starting the timer
  local startPos = recordedPoints[1]
  local nextPos = recordedPoints[2] or startPos -- Handle paths with only one segment (2 points)
  currentActualLookAt = nextPos -- Start by looking directly at the second point

  -- Create the timer *before* storing it, so updateCameraFly closure captures the correct handle
  local newTimer = setTimer(updateCameraFly, timerInterval, 0) -- 0 = repeat indefinitely

  -- Store timer handle and callback in the global state
  activeFlyAnimation.timer = newTimer
  activeFlyAnimation.callback = onCompleteCallback

  -- Initial camera setup at the very start
  setCameraMatrix(startPos.x, startPos.y, startPos.z,
                  nextPos.x, nextPos.y, nextPos.z)

end


-- =============================================================================
-- Cancel Function
-- =============================================================================

--[[
  Cancels the currently active camera fly-through animation, if any.
  Will trigger the completion callback that was provided to cameraFly.

  Returns:
    boolean: true if an animation was cancelled, false otherwise.
]]
function cancelCameraFly()
  if activeFlyAnimation.timer and isTimer(activeFlyAnimation.timer) then
    print("Cancelling active camera fly-through via cancelCameraFly().")
    local callbackToCall = activeFlyAnimation.callback -- Get callback before clearing state

    -- Kill the timer and clear the state
    killTimer(activeFlyAnimation.timer)
    activeFlyAnimation.timer = nil
    activeFlyAnimation.callback = nil
    -- Note: 'currentActualLookAt' state lives within the timer closure and will be garbage collected.

    -- Call the completion callback if it exists
    if type(callbackToCall) == "function" then
      pcall(callbackToCall) -- Use pcall for safety
    end
    return true -- Indicate cancellation happened
  else
    -- print("No active camera fly-through to cancel.") -- Optional message
    return false -- Indicate nothing was cancelled
  end
end

-- =============================================================================
-- Example Usage (Commented Out)
-- =============================================================================
--[[

-- Assuming you have:
-- local myPlayer = getLocalPlayer() -- Function to get the player element
-- local myPath = { {x=10,y=10,z=5}, {x=20,y=12,z=5}, {x=30,y=15,z=6}, {x=35,y=20,z=6}, {x=30,y=25,z=5} } -- Your list of points

local function onFlyComplete()
    print("FLY CAM FINISHED!")
    -- Example: Give camera control back to player
    -- if isElement(myPlayer) then
    --     setCameraTarget(myPlayer)
    -- end
end

-- Start the camera fly
-- cameraFly(myPath, myPlayer, 1.5, onFlyComplete, { lookAtSmoothFactor = 0.08 })

-- To stop it early from somewhere else:
-- cancelCameraFly()

]]