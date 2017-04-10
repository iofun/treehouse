-- A simple ship which tends to fly in flocks.

local this_ship = {}		-- Our this_ship function table

-- The standard local variables
local x, y, dx, dy		-- Where we are and fast we move
local colour = "orange"		-- Our colour
local style = "ship"		-- Our style
local tick			-- Size of a clock tick msec
local me = ship.self()		-- This is me
local ammo,shield = 0,0

local xsize,ysize = universe.size()	-- The size of the universe

local dphi = 0                  -- current effective torque

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
      nx = x - dx
      dx = -dx
   end
   if (not valid_y(ny)) then	-- Bounce off the edge
      ny = y - dy
      dy = -dy
   end
   return nx, ny, dx, dy
end

local function move_lr_sectors(osx, osy, nsx, nsy)
   local idx,idy = nsx-osx,nsy-osy
   local lsx,lsy,rsx,rsy	-- Left, right of next sectors
   if (idx == 0) then
      lsx,lsy = nsx - idy,nsy
      rsx,rsy = nsx + idy,nsy
   elseif (idy == 0) then
      lsx,lsy = nsx,nsy - idx
      rsx,rsy = nsx,nsy + idx
   elseif (idx == idy) then
      lsx,lsy = nsx - idx, nsy
      rsx,rsy = nsx, nsy - idy
   else				-- idx ~= idy
      lsx,lsy = nsx,nsy - idx
      rsx,rsy = nsx - idx,nsy
   end
   return lsx,lsy,rsx,rsy
end

local function move_xy_follow(x, y, dx, dy)
   -- Where we were and where we are now.
   local nx,ny = x+dx,y+dy
   local osx,osy = universe.sector(x, y)
   local nsx,nsy = universe.sector(nx, ny)
   if (osx == nsx and osy == nsy) then
      return false,nx,ny,dx,dy
   end
   local lsx,lsy,rsx,rsy = move_lr_sectors(osx, osy, nsx, nsy)
   local f = universe.get_sector(nsx, nsy) or
      universe.get_sector(lsx, lsy) or
      universe.get_sector(rsx, rsy)
   if (f) then
      local fx,fy = ship.get_pos(f)
      local fdx,fdy = ship.get_speed(f)
      colour = "green"
      return true,x,y,fdx,fdy
   else
      return true,x,y,dx,dy
   end
end

local function move(x, y, dx, dy)
   local new,nx,ny,ndx,ndy = move_xy_follow(x, y, dx, dy)
   nx,ny,ndx,ndy = move_xy_bounce(nx, ny, ndx, ndy,
				  universe.valid_x, universe.valid_y)
   if (new) then
      -- In new sector, move us to the right sector
      universe.rem_sector(x, y)
      universe.add_sector(nx, ny)
      -- and draw us
      esdl_server.set_ship(style, colour, nx, ny)
   end
   return nx,ny,ndx,ndy
end

function this_ship.tick()
   x,y,dx,dy = move(x, y, dx, dy)
end

function this_ship.zap()	-- The ship has been zapped and will die
   esdl_server.set_ship("explosion", colour, x, y)
   universe.rem_sector(x, y)
end

return this_ship		-- Return this ship table
