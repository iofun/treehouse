-- A simple ship which is aggressive and attacks.
-- When it going to change sector and sees another ship in that sector
-- it tries to zap it.

local this_ship = {}		-- Our ship function table

-- The standard local variables
local x, y, dx, dy		-- Where we are and fast we move
local colour = "red"		-- Our default colour
local style = "ship"		-- Our style
local tick			-- Size of a clock tick msec
local me = ship.self()		-- This is me
local ammo,shield = 0,0

local xsize,ysize = universe.size()	-- The size of the universe

-- The default ship interface.

function this_ship.start() end

function this_ship.get_pos() return x,y end

function this_ship.set_pos(a1, a2) x,y = a1,a2 end

function this_ship.get_speed() return dx,dy end

function this_ship.set_speed(a1, a2) dx,dy = a1,a2 end

function this_ship.set_tick(a1) tick = a1 end

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
   return nx,ny,dx,dy
end

-- Calculate the left/right sectors of the sector to which we are going.
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

local function zap_ships(osx, osy, nsx, nsy)
   local lsx,lsy,rsx,rsy = move_lr_sectors(osx, osy, nsx, nsy)
   local f = universe.get_sector(nsx, nsy)
   if (f and f ~= me) then	-- Always zap ship in front
      ship.zap(f)
   end
   f = universe.get_sector(lsx, lsy) or
      universe.get_sector(rsx, rsy)
   if (f and f ~= me) then	-- Zap ship either left or right
      ship.zap(f)
   end
end

local function move(x, y, dx, dy)
   local nx,ny,ndx,ndy = move_xy_bounce(x, y, dx, dy,
					universe.valid_x, universe.valid_y)
   -- Where we were and where we are now.
   local osx,osy = universe.sector(x, y)
   local nsx,nsy = universe.sector(nx, ny)
   if (osx ~= nsx or osy ~= nsy) then
      -- Zap a nearby ships, only zap when we move
      zap_ships(osx, osy, nsx, nsy)
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

return this_ship		-- Return the ship table
