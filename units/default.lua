-- The default unit.
-- It reflects from the edge.

local this_unit = {}                -- Our unit function table

-- The standard local variables
local x, y, dx, dy                  -- Where we are and fast we move
local color = "white"               -- Our color
local style = "unit"                -- Our style
local tick                          -- Size of a clock tick msec
local me = unit.self()              -- This is me
local ammo,shield = 0,0

local xsize,ysize = region.size()   -- The size of the region

-- The default unit interface.

function this_unit.start() end

function this_unit.get_position() return x,y end

function this_unit.set_position(a1, a2) x,y = a1,a2 end

function this_unit.get_speed() return dx,dy end

function this_unit.set_speed(a1, a2) dx,dy = a1,a2 end

function this_unit.set_tick(a1) tick = a1 end

local function move_xy_bounce(x, y, dx, dy, valid_x, valid_y)
   local nx = x + dx
   local ny = y + dy
   if (not valid_x(nx)) then       -- Bounce off the edge
      nx = x - dx
      dx = -dx
   end
   if (not valid_y(ny)) then       -- Bounce off the edge
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

function this_unit.zap()           -- The unit has been zapped and will die
   region.rem_sector(x, y)
end

return this_unit                   -- Return the unit table