-- Follow ship behavior.

local this_ship = {}            -- Our ship function table

-- The standard local variables
local x, y                      -- Where we are
local colour = "blue"          -- Our colour
local style = "ship"		-- Our style
local tick                      -- Size of a clock tick msec
local me = ship.self()		-- This is me
local ammo,shield = 0,0

local xsize,ysize = universe.size()     -- The size of the universe

local phi = 0                   -- Direction
local dphi = 0.1                -- Current turn angle per frame
local mdphi = 0.1               -- Max turn angle (abs)
local v = 1                     -- Speed
local maxv = 1                  -- Speed (abs)
local a = 0                     -- Acceleration
local da = 0                    -- Acceleration change per frame
local maxda = 0.001             -- Max acceleration change per frame
local tda = 10                  -- Frames left until setting of new da
local maxtda = 100              -- Max when setting new tda
local mintda = 5                -- Min when setting new tda
local leader = nil              -- Who are we following

-- The default ship interface.

function this_ship.start() end

function this_ship.get_pos() return x,y end

function this_ship.set_pos(a1, a2)
   x,y = a1,a2
   math.randomseed(a1+a2)
end

function this_ship.get_speed() return v,0 end

function this_ship.set_speed(a1, a2)
  phi = math.atan2(a2,a1)
  v = math.sqrt(a1*a1+a2*a2)
end

function this_ship.set_tick(a1) tick = a1 end

-- Movement
local function move()
  -- follow leader
  if leader then
      -- relative position to leader
      local fx,fy = ship.get_pos(leader)
      local ldx = fx-x
      local ldy = fy-y
      local lphi = math.atan2(ldy,ldx)
      local lv = math.sqrt(ldx*ldx+ldy*ldy)
      if lv < 4 then
        v = 0.1; a = 0; da = 0; lphi = lphi + math.pi
      end
      -- turn towards it to allowed degree
      local desired_correction = lphi - phi
      dphi = math.min(mdphi, math.max(-mdphi, desired_correction))
      -- faster the further away
      maxv = 3
      a = 0.01
      da = 0
      if math.abs(desired_correction) > 1 then a = -0.01 end
  end

   -- free random
  if not leader then
     tda = tda - 1
     -- new free random course
     if tda <= 0 then
        a = 0
        tda = math.random(mintda, maxtda)
        da = math.random(-100000*maxda, 100000*maxda)/100000
        dphi = math.random(-100000*mdphi, 100000*mdphi)/100000
     end
   end

   -- acceleration and turning
   phi = phi + dphi
   a = a + da
   v = math.max(.1, math.min(maxv, v + a))

   -- move
   local nx = x + v * math.cos(phi)
   local ny = y + v * math.sin(phi)
   -- allowed move
   if universe.valid_x(nx) and universe.valid_y(ny) then
     local x0,y0 = x,y
     x,y = nx,ny
     -- Sectors: Where we were and where we are now.
     local osx,osy = universe.sector(x0, y0)
     local nsx,nsy = universe.sector(x, y)
     if (osx ~= nsx or osy ~= nsy) then
        -- In new sector, move us to the right sector
        universe.rem_sector(x0, y0)
        universe.add_sector(x, y)
        -- and draw us
        esdl_server.set_ship(style, colour, x, y)
     end
     -- Leader: get one, if someone is close. for next time
     if not leader then
       leader =
         universe.get_sector(nsx+1, nsy+1) or
         universe.get_sector(nsx+1, nsy) or
         universe.get_sector(nsx+1, nsy-1)
       if leader then
          colour = "yellow"
       end
     end
   -- disallowed move: stick to wall.
   else
     dphi = 0.01
   end
end

function this_ship.tick()
   move()
end

function this_ship.zap()	-- The ship has been zapped and will die
   esdl_server.set_ship("explosion", colour, x, y)
   universe.rem_sector(x, y)
end

return this_ship                -- Return the ship table
