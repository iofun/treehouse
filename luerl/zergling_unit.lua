-- Zerglings can be morphed after construction of the Spawning Pool. 

-- Our unit function table
local this_unit = {}
-- Where we are and fast we move
local x, y, dx, dy
-- Our color
local color = "red"
-- Our label
local label = "zerg_unit"
-- Our category
local category = "small_ground"
-- Size of a clock tick msec
local tick
-- It's me, the unit structure             
local me = unit.self()
-- The standard local variables
local armor = 0
local hitpoints,shield = 35,0
local ground_damage,air_damage = 5,0
local ground_cooldown, air_cooldown = 0.336,0
local ground_range, air_range = 1,0
local sight = 5
local speed = 4.144
local supply = 0.5
local cooldown = 18
local mineral = 25
local gas = 0
local holdkey = "z"

-- The size of the region
local xsize,ysize = region.size()

-- The unit interface.

function this_unit.start() end

function this_unit.get_position() return x,y end

function this_unit.set_position(a1, a2) x,y = a1,a2 end

function this_unit.get_speed() return dx,dy end

function this_unit.set_speed(a1, a2) dx,dy = a1,a2 end

function this_unit.set_tick(a1) tick = a1 end

local function move_xy_bounce(x, y, dx, dy, valid_x, valid_y)
   local nx = x + dx
   local ny = y + dy
   -- Bounce off the edge
   if (not valid_x(nx)) then
      nx = x - dx
      dx = -dx
   end
   -- Bounce off the edge
   if (not valid_y(ny)) then
      ny = y - dy
      dy = -dy
   end
   return nx, ny, dx, dy
end

local function move(x, y, dx, dy)
   local nx,ny,ndx,ndy = move_xy_bounce(x, y, dx, dy,
               region.valid_x, region.valid_y)
   -- Where we were and where we are now.
   local osx,osy = region.sector(x, y)
   local nsx,nsy = region.sector(nx, ny)
   if (osx ~= nsx or osy ~= nsy) then
      -- In new sector, move us to the right sector
      region.rem_sector(x, y)
      region.add_sector(nx, ny)
   end
   return nx,ny,ndx,ndy
end

function this_unit.tick()
   x,y,dx,dy = move(x, y, dx, dy)
end

function this_unit.attack()
   -- The unit has been zapped and will die
   region.rem_sector(x, y)
end

-- Return the unit table
return this_unit