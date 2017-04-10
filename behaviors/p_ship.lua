local this_ship = {}		-- Our ship function table

local x, y, dx, dy		-- Where we are and fast we move
local colour = "yellow"		-- Our colour
local type = "ship"		-- Our type
local tick			-- Size of a clock tick msec
local me = ship.self()		-- This is me
local ammo,shield = 0,0

local xsize, ysize		-- The size of the universe

-- The default ship interface.

function this_ship.start() end

function this_ship.get_pos() return x,y end

function this_ship.set_pos(a1, a2) x,y = a1,a2 end

function this_ship.get_speed() return dx,dy end

function this_ship.set_speed(a1, a2) dx,dy = a1,a2 end

function this_ship.set_tick(a1) tick = a1 end

local function move(x, y, dx, dy)
   local move_xy = function (a, da, valid)
      local na = a + da
      if valid(na) then
	 return na,da
      else
	 colour = "yellow"
	 type = "extra"
	 return a-da,-da
      end
   end
   local nx,ndx = move_xy(x, dx, universe.valid_x)
   local ny,ndy = move_xy(y, dy, universe.valid_y)
   -- Where we were and where we are now.
   oldsx,oldsy = universe.sector(x, y)
   newsx,newsy = universe.sector(nx, ny)
   if (oldsx == newsx and oldsy == newsy) then
      -- Same sector, just set the values
      return nx,ny,ndx,ndy
   else
      -- Simple avoidance scheme
      if (universe.get_sector(nx, ny)) then
	 -- Something there, change colour, pause and reverse
	 -- print("reverse",x,y,dx,dy)
	 colour = "red"
	 if (nx ~= x) then dx = -dx end
	 if (ny ~= y) then dy = -dy end
	 return x,y,dx,dy
      else
	 -- In new sector, move us to the right sector
	 universe.rem_sector(x, y)
	 universe.add_sector(nx, ny)
	 -- and draw us
	 esdl_server.set_ship(type, colour, nx, ny)
	 return nx,ny,ndx,ndy
      end
   end
end

function this_ship.tick()
   x,y,dx,dy = move(x, y, dx, dy)
end

function this_ship.zap()	-- The ship has been zapped and will die
   esdl_server.set_ship("explosion", colour, x, y)
   universe.rem_sector(x, y)
end

return this_ship
