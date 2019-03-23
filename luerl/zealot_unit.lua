-- The Zealot is the Protoss first tier melee unit. Zealots only deal damage to ground units, so are vulnerable to air attack units.

-- Our unit function table
local this_unit = {}

-- The standard local variables

-- Where we are and fast we move
local x, y, dx, dy
-- Our color
local color = "green"
-- Our BWAPI unit type
local type = 65
-- Size of a clock tick msec
local tick

-- This is me              
local me = unit.self()

-- and now for something completely different
local label = "small_ground"
local armor = 1
local hitpoints,shield = 100,60
local ground_damage,air_damage = 8,0
local ground_cooldown, air_cooldown = 0.924,0
local ground_range, air_range = 1,0
local sight = 7
local supply = 2
local cooldown = 25
local mineral = 100
local gas = 0

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
