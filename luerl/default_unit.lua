-- The default unit reflects from the edge.

local this_unit = {}		    -- Our unit function table

-- The standard local variables
local x, y, dx, dy		        -- Where we are and fast we move
local colour = "white"		    -- Our colour
local type = "unit"	    	    -- Our type
local tick			            -- Size of a clock tick msec
local me = unit.self()		    -- This is me
local ammo,shield = 0,0

local xsize,ysize = map.size()	-- The size of the map 

-- The default unit interface.

function this_unit.start() end

function this_unit.get_pos() return x,y end

function this_unit.set_pos(a1, a2) x,y = a1,a2 end

function this_unit.get_speed() return dx,dy end

function this_unit.set_speed(a1, a2) dx,dy = a1,a2 end

function this_unit.set_tick(a1) tick = a1 end

local function move_xy_bounce(x, y, dx, dy, valid_x, valid_y)
   local nx = x + dx
   local ny = y + dy

   if (not valid_x(nx)) then    -- Bounce off the edge
      nx = x - dx
      dx = -dx
   end
   if (not valid_y(ny)) then	-- Bounce off the edge
      ny = y - dy
      dy = -dy
   end
   return nx, ny, dx, dy
end

local function move(x, y, dx, dy)
   local nx,ny,ndx,ndy = move_xy_bounce(x, y, dx, dy,
					map.valid_x, map.valid_y)
   -- Where we were and where we are now.
   local osx,osy = map.sector(x, y)
   local nsx,nsy = map.sector(nx, ny)
   if (osx ~= nsx or osy ~= nsy) then
      -- In new sector, move us to the right sector
      map.rem_sector(x, y)
      map.add_sector(nx, ny)
      -- and draw us
      esdl_server.set_unit(type, colour, nx, ny)
   end
   return nx,ny,ndx,ndy
end

function this_unit.tick()
   x,y,dx,dy = move(x, y, dx, dy)
end

function this_unit.attack()	-- The unit has been attacked and will die
   esdl_server.set_unit("explosion", colour, x, y)
   map.rem_sector(x, y)
end

return this_unit		-- Return the unit table
