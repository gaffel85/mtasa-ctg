-- Funktion för att skapa en vektor
local function vector(x, y, z)
    return { x = x, y = y, z = z }
end
  
  -- Funktion för att rotera en vektor runt x-axeln (pitch)
local function rotate_x(v, angle)
    local rad = math.rad(angle)
    local sin_a = math.sin(rad)
    local cos_a = math.cos(rad)
    return vector(
      v.x,
      v.y * cos_a - v.z * sin_a,
      v.y * sin_a + v.z * cos_a
    )
end
  
  -- Funktion för att rotera en vektor runt y-axeln (yaw)
local function rotate_y(v, angle)
    local rad = math.rad(angle)
    local sin_a = math.sin(rad)
    local cos_a = math.cos(rad)
    return vector(
      v.x * cos_a + v.z * sin_a,
      v.y,
      -v.x * sin_a + v.z * cos_a
    )
end
  
  -- Funktion för att rotera en vektor runt z-axeln (roll)
local function rotate_z(v, angle)
    local rad = math.rad(angle)
    local sin_a = math.sin(rad)
    local cos_a = math.cos(rad)
    return vector(
      v.x * cos_a - v.y * sin_a,
      v.x * sin_a + v.y * cos_a,
      v.z
    )
end
  
  -- Funktion för att rotera en vektor med Euler-vinklar (yaw, pitch, roll)
function rotate_euler(v, pitch, yaw, roll)
    local rotated = v
    rotated = rotate_y(rotated, yaw)
    rotated = rotate_x(rotated, pitch)
    rotated = rotate_z(rotated, roll)
    return rotated
end
  
  -- Funktion för att beräkna skärningspunkten med z-axeln
function z_axis_intersection(normal_vector, point)
    -- Ekvationen för planet är: Ax + By + Cz = D
    -- normal_vector är (A, B, C)
    -- point är en punkt på planet (i detta fall, spetsen av den roterade vektorn)
  
    local A = normal_vector.x
    local B = normal_vector.y
    local C = normal_vector.z
    local x0 = point.x
    local y0 = point.y
    local z0 = point.z
  
    -- Beräkna D: D = Ax0 + By0 + Cz0
    local D = A * x0 + B * y0 + C * z0
  
    -- Skärningspunkt med z-axeln: x = 0, y = 0
    -- Cz = D  =>  z = D / C
    if C == 0 then
      return nil -- Planet är parallellt med z-axeln, ingen skärningspunkt.
    else
      local z_intersect = D / C
      return z_intersect
    end
  end
  
  --[[
  -- Användningsexempel
  local my_vector = vector(0, 0, -2) -- Din ursprungliga vektor
  local yaw_angle = 45        -- Rotation runt y-axeln
  local pitch_angle = 30      -- Rotation runt x-axeln
  local roll_angle = 0        -- Rotation runt z-axeln
  
  local rotated_vector = rotate_euler(my_vector, yaw_angle, pitch_angle, roll_angle)
  
  print("Original vector: ", my_vector.x, my_vector.y, my_vector.z)
  print("Rotated vector: ", rotated_vector.x, rotated_vector.y, rotated_vector.z)
  
  local intersection_z = z_axis_intersection(rotated_vector, rotated_vector)
  
  if intersection_z then
    print("Z-axis intersection: z = ", intersection_z)
  else
    print("No intersection with z-axis.")
  end
  ]]--