-- A simple unit which is aggressive and attacks on
-- change sector and sees another unit in that sector.

local this_unit = {}                -- Our unit function table

-- The standard local variables
local x, y, dx, dy                  -- Where we are and fast we move
local color = "red"                 -- Our default color
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
   if (not valid_x(nx)) then        -- Bounce off the edge
      nx = x - dx
      dx = -dx
   end
   if (not valid_y(ny)) then        -- Bounce off the edge
      ny = y - dy
      dy = -dy
   end
   return nx, ny, dx, dy
end

-- Calculate the left/right sectors of the sector to which we are going.
local function move_lr_sectors(osx, osy, nsx, nsy)
   local idx,idy = nsx-osx,nsy-osy
   local lsx,lsy,rsx,rsy            -- Left, right of next sectors
   if (idx == 0) then
      lsx,lsy = nsx - idy,nsy
      rsx,rsy = nsx + idy,nsy
   elseif (idy == 0) then
      lsx,lsy = nsx,nsy - idx
      rsx,rsy = nsx,nsy + idx
   elseif (idx == idy) then
      lsx,lsy = nsx - idx, nsy
      rsx,rsy = nsx, nsy - idy
   else           -- idx ~= idy
      lsx,lsy = nsx,nsy - idx
      rsx,rsy = nsx - idx,nsy
   end
   return lsx,lsy,rsx,rsy
end

local function attack_units(osx, osy, nsx, nsy)
   local lsx,lsy,rsx,rsy = move_lr_sectors(osx, osy, nsx, nsy)
   local f = region.get_sector(nsx, nsy)
   if (f and f ~= me) then          -- Always attack unit in front
      unit.attack(f)
   end
   f = region.get_sector(lsx, lsy) or
      region.get_sector(rsx, rsy)
   if (f and f ~= me) then          -- Attack unit either left or right
      unit.attack(f)
   end
end

local function move(x, y, dx, dy)
   local nx,ny,ndx,ndy = move_xy_bounce(x, y, dx, dy,
               region.valid_x, region.valid_y)
   -- Where we were and where we are now.
   local osx,osy = region.sector(x, y)
   local nsx,nsy = region.sector(nx, ny)
   if (osx ~= nsx or osy ~= nsy) then
      -- Attack a nearby units, only attack when we move
      attack_units(osx, osy, nsx, nsy)
      -- In new sector, move us to the right sector
      region.rem_sector(x, y)
      region.add_sector(nx, ny)
   end
   return nx,ny,ndx,ndy
end

function this_unit.tick()
   x,y,dx,dy = move(x, y, dx, dy)
end

function this_unit.attack()            -- The unit has been zapped and will die
   region.rem_sector(x, y)
end

return this_unit                    -- Return the unit table
