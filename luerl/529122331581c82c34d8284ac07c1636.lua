-- Hive-tech air-to-air unit that requires a Greater Spire 
-- to morph from a Mutalisk, through a Cocoon.

-- Our unit function table
local this_unit = {}
-- Where we are and fast we move
local x, y, dx, dy
-- Our name
local name = "Zerg_Devourer"
-- Our color
local color = "red"
-- Our BWAPI unit type
local type = 62
-- Our label
local label = "zerg_unit"
-- Our category
local category = "large_air"
-- Size of a clock tick msec
local tick
-- It's me, the unit structure               
local me = unit.self()
-- The standard local variables
local armor = 2
local hitpoints,shield = 250,0
local ground_damage,air_damage = 0,25
local ground_cooldown,air_cooldown = 0,4.2
local ground_range,air_range = 0,6
local sight = 10
local speed = 3.720
local supply = 2
local cooldown = 50
local mineral = 250
local gas = 150
local holdkey = "d"

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
