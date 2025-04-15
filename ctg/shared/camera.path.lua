-- (Keep the existing helper functions: vecLength, vecSubtract, vecAdd, vecScale, catmullRomInterpolate, vecLerp)

local currentFlyTimer = nil -- Variable to hold the active timer
local currentActualLookAt = nil -- Variable to store the smoothed look-at target across frames

--[[
  Creates a smooth camera fly-through along a recorded path with optional look-at smoothing.

  Args:
    recordedPoints (table): A list of points {x, y, z}. Must contain at least 2 points.
    playerToShowTheCameraFor (player): The player element the camera belongs to.
    cameraFlySpeed (number): A value controlling speed along the path.
    options (table, optional): A table for additional settings:
      options.lookAtSmoothFactor (number): Controls look-at smoothing (0.0 to 1.0).
                                           Lower values = smoother/more damped rotation.
                                           1.0 = no smoothing (instant look-at).
                                           Default: 0.1 (adjust as needed)
]]
function cameraFly(recordedPoints, playerToShowTheCameraFor, cameraFlySpeed, options)
  -- Stop any previous fly-through
  if isTimer(currentFlyTimer) then
    killTimer(currentFlyTimer)
    currentFlyTimer = nil
  end
  currentActualLookAt = nil -- Reset smoothed look-at

  -- Validate input
  if not recordedPoints or #recordedPoints < 2 then
    print("Error: cameraFly requires at least 2 recorded points.")
    return
  end
  if not isElement(playerToShowTheCameraFor) then
     print("Error: cameraFly requires a valid player element.")
     return
  end

  -- Options setup
  options = options or {}
  local lookAtSmoothFactor = options.lookAtSmoothFactor or 0.1 -- Default smoothing factor
  -- Clamp the factor to prevent unexpected behavior
  lookAtSmoothFactor = math.max(0.01, math.min(1.0, lookAtSmoothFactor)) -- Keep it between 0.01 (to ensure it moves) and 1.0

  -- Animation state variables
  local currentSegment = 1
  local t = 0.0
  local numPoints = #recordedPoints
  local numSegments = numPoints - 1

  -- Constants for the animation loop
  local timerInterval = 50
  local lookAheadFactor = 0.05 -- Keep this for calculating the *target* look-at

  -- --- The Timer Callback Function ---
  local function updateCameraFly()
    -- Calculate control points (p0, p1, p2, p3) - SAME AS BEFORE
    local p0, p1, p2, p3
    p1 = recordedPoints[currentSegment]
    p2 = recordedPoints[currentSegment + 1]
    if currentSegment == 1 then p0 = p1 else p0 = recordedPoints[currentSegment - 1] end
    if currentSegment >= numSegments then p3 = p2 else p3 = recordedPoints[currentSegment + 2] end

    -- Calculate TARGET camera position on the spline
    local targetCamPos = catmullRomInterpolate(p0, p1, p2, p3, t)

    -- Calculate TARGET look-at position (slightly ahead on spline)
    local lookAtT = math.min(t + lookAheadFactor, 1.0)
    local targetLookAtPos = catmullRomInterpolate(p0, p1, p2, p3, lookAtT)

    -- Handle edge case where target look-at is same as target position - SAME AS BEFORE
    if vecLength(vecSubtract(targetCamPos, targetLookAtPos)) < 0.01 then
        if vecLength(vecSubtract(targetCamPos, p2)) < 0.01 then
            if currentSegment < numSegments then
                targetLookAtPos = recordedPoints[currentSegment + 2]
            else
                 targetLookAtPos = { x = targetCamPos.x + 0.1, y = targetCamPos.y, z = targetCamPos.z } -- Fallback
            end
        else
             targetLookAtPos = p2
        end
    end

    -- Initialize or Smooth the ACTUAL Look-At Position
    if not currentActualLookAt then
        -- First frame, set the actual look-at directly to the target
        currentActualLookAt = targetLookAtPos
    else
        -- Subsequent frames: Lerp the actual look-at towards the target
        currentActualLookAt = vecLerp(currentActualLookAt, targetLookAtPos, lookAtSmoothFactor)
    end

    -- Set the camera matrix using the TARGET position and the SMOOTHED look-at
    setCameraMatrix(playerToShowTheCameraFor,
                    targetCamPos.x, targetCamPos.y, targetCamPos.z,
                    currentActualLookAt.x, currentActualLookAt.y, currentActualLookAt.z) -- Use the smoothed look-at

    -- Update interpolation factor 't' - SAME AS BEFORE
    local segmentLengthApprox = vecLength(vecSubtract(p2, p1))
    local deltaT = 0
    if segmentLengthApprox > 0.001 then
         deltaT = (cameraFlySpeed * (timerInterval / 1000)) / segmentLengthApprox
    else
        deltaT = 1.0
    end
    t = t + deltaT

    -- Move to the next segment - SAME AS BEFORE
    if t >= 1.0 then
      currentSegment = currentSegment + 1
      t = 0.0
      if currentSegment > numSegments then
        print("Camera fly-through finished.")
        if isTimer(currentFlyTimer) then
          killTimer(currentFlyTimer)
          currentFlyTimer = nil
        end
        -- Optional: Final snap
        local finalPos = recordedPoints[numPoints]
        -- For the final lookAt, we might want to use the last calculated target or the smoothed one
        setCameraMatrix(playerToShowTheCameraFor, finalPos.x, finalPos.y, finalPos.z,
                        currentActualLookAt.x, currentActualLookAt.y, currentActualLookAt.z)
        currentActualLookAt = nil -- Clear state
        return
      end
    end
  end

  -- Start the timer
  print("Starting camera fly-through...")
  -- Initialize the currentActualLookAt before starting the timer
  local startPos = recordedPoints[1]
  local nextPos = recordedPoints[2]
  currentActualLookAt = nextPos -- Start by looking directly at the second point

  currentFlyTimer = setTimer(updateCameraFly, timerInterval, 0)

  -- Initial camera setup
  setCameraMatrix(playerToShowTheCameraFor,
                  startPos.x, startPos.y, startPos.z,
                  nextPos.x, nextPos.y, nextPos.z)
end