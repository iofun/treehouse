local this_unit = {}		-- Our unit function table

local x, y, dx, dy		-- Where we are and fast we move
local color = "yellow"		-- Our color
local type = "unit"		-- Our type
local tick			-- Size of a clock tick msec
local me = unit.self()		-- This is me
local ammo,shield = 0,0

local xsize, ysize		-- The size of the region

-- The default unit interface.

function this_unit.start() end

function this_unit.get_position() return x,y end

function this_unit.set_position(a1, a2) x,y = a1,a2 end

function this_unit.get_speed() return dx,dy end

function this_unit.set_speed(a1, a2) dx,dy = a1,a2 end

function this_unit.set_tick(a1) tick = a1 end

local function move(x, y, dx, dy)
   local move_xy = function (a, da, valid)
      local na = a + da
      if valid(na) then
	 return na,da
      else
	 color = "yellow"
	 type = "extra"
	 return a-da,-da
      end
   end
   local nx,ndx = move_xy(x, dx, region.valid_x)
   local ny,ndy = move_xy(y, dy, region.valid_y)
   -- Where we were and where we are now.
   oldsx,oldsy = region.sector(x, y)
   newsx,newsy = region.sector(nx, ny)
   if (oldsx == newsx and oldsy == newsy) then
      -- Same sector, just set the values
      return nx,ny,ndx,ndy
   else
      -- Simple avoidance scheme
      if (region.get_sector(nx, ny)) then
	 -- Something there, change color, pause and reverse
	 -- print("reverse",x,y,dx,dy)
	 color = "red"
	 if (nx ~= x) then dx = -dx end
	 if (ny ~= y) then dy = -dy end
	 return x,y,dx,dy
      else
	 -- In new sector, move us to the right sector
	 region.rem_sector(x, y)
	 region.add_sector(nx, ny)
	 return nx,ny,ndx,ndy
      end
   end
end

function this_unit.tick()
   x,y,dx,dy = move(x, y, dx, dy)
end

function this_unit.zap()	-- The unit has been zapped and will die
   region.rem_sector(x, y)
end

return this_unit
