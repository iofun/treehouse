-- A simple ship which is "timid".
-- When it going to change sector and sees another ship in that sector
-- it halts, changes colour to pink, then goes backwards. When it
-- reflects from the edge it changes back to white.

local this_ship={};		-- Our ship function table

-- The standard local variables
local x, y, dx, dy		-- Where we are and fast we move
local colour = "white"		-- Our default colour
local style = "ship"		-- Our style
local tick			-- Size of a clock tick msec
local me = ship.self()		-- This is me
local ammo,shield = 0,0

local xsize,ysize = universe.size()	-- The size of the universe

-- The default ship interface.

function this_ship.start() end

function this_ship.get_pos() return x,y; end

function this_ship.set_pos(a1, a2) x,y = a1,a2; end

function this_ship.get_speed() return dx,dy; end

function this_ship.set_speed(a1, a2) dx,dy = a1,a2; end

function this_ship.set_tick(a1) tick = a1; end

local function move_xy_bounce(x, y, dx, dy, valid_x, valid_y)
   local nx = x + dx
   local ny = y + dy

   if (not valid_x(nx)) then	-- Bounce off the edge
      colour = "white"		-- Go back to white when we bounce
      nx = x - dx
      dx = -dx
   end
   if (not valid_y(ny)) then	-- Bounce off the edge
      colour = "white"		-- Go back to white when we bounce
      ny = y - dy
      dy = -dy
   end
   return nx, ny, dx, dy
end

local function move(x, y, dx, dy)
   local nx,ny,ndx,ndy = move_xy_bounce(x, y, dx, dy,
					universe.valid_x, universe.valid_y)
   -- Where we were and where we are now.
   local osx,osy = universe.sector(x, y)
   local nsx,nsy = universe.sector(nx, ny)
   if (osx == nsx and osy == nsy) then
      -- Same sector, just set the values
      return nx,ny,ndx,ndy
   else
      -- Simple avoidance scheme
      if (universe.get_sector(nx, ny)) then
	 -- Something there, change colour, pause and reverse
	 colour = "yellow"
	 return x,y,-dx,-dy
      else
	 -- In new sector, move us to the right sector
	 universe.rem_sector(x, y)
	 universe.add_sector(nx, ny)
	 -- and draw us
	 esdl_server.set_ship(style, colour, nx, ny)
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

return this_ship		-- Return the ship table
