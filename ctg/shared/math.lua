-- Basic Vector Operations
local function vecLength(v)
    return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
  end
  
  local function vecSubtract(v1, v2)
    return { x = v1.x - v2.x, y = v1.y - v2.y, z = v1.z - v2.z }
  end
  
  local function vecAdd(v1, v2)
      return { x = v1.x + v2.x, y = v1.y + v2.y, z = v1.z + v2.z }
  end
  
  local function vecScale(v, scalar)
    return { x = v.x * scalar, y = v.y * scalar, z = v.z * scalar }
  end
  
  -- Catmull-Rom Spline Interpolation
  -- p0, p1, p2, p3 are points {x, y, z}
  -- t is the interpolation factor (0.0 to 1.0) between p1 and p2
  local function catmullRomInterpolate(p0, p1, p2, p3, t)
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