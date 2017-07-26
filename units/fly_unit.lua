-- Fly unit behavior.
-- It randomly circles about and sits on the edge.

local this_unit = {}                -- Our unit function table

-- The standard local variables
local x0, y0, x, y                  -- Where we are
local color = "cyan"                -- Our color
local style = "unit"                -- Our style
local tick                          -- Size of a clock tick msec
local me = unit.self()              -- This is me
local ammo,shield = 0,0

local xsize,ysize = region.size()   -- The size of the region

local phi = 0                       -- Direction
local dphi = 0.1                    -- Current turn angle per frame
local mdphi = 0.1                   -- Max turn angle (abs)
local v = 1                         -- Speed
local a = 0                         -- Acceleration
local da = 0                        -- Acceleration change per frame
local maxda = 0.001                 -- Max acceleration change per frame
local tda = 10                      -- Frames left until setting of new da
local maxtda = 100                  -- Max when setting new tda
local mintda = 5                    -- Min when setting new tda

-- The default unit interface.

function this_unit.start() end

function this_unit.get_pos() return x,y end

function this_unit.set_pos(a1, a2)
  x,y = a1,a2
  math.randomseed(a1+a2)
end

function this_unit.get_speed() return v,0 end

function this_unit.set_speed(a1, a2)
  phi = math.atan2(a2,a1)
  v = math.sqrt(a1*a1+a2*a2)
end

function this_unit.set_tick(a1) tick = a1 end

local function move_xy(x, y, valid_x, valid_y)
   tda = tda - 1
   if tda <= 0 then
        a = 0
        tda = math.random(mintda, maxtda)
        da = math.random(-100000*maxda, 100000*maxda)/100000
        dphi = math.random(-100000*mdphi, 100000*mdphi)/100000
   end
   phi = phi + dphi
   a = a + da
   v = v + a
   local nx = x + v * math.cos(phi)
   local ny = y + v * math.sin(phi)
   if valid_x(nx) and valid_y(ny) then
      return nx,ny
   else
      dphi = 0.01
      return x,y
   end
end

local function move(x, y)
   local nx,ny = move_xy(x, y, region.valid_x, region.valid_y)
   -- Sectors: Where we were and where we are now.
   local osx,osy = region.sector(x, y)
   local nsx,nsy = region.sector(nx, ny)
   if (osx ~= nsx or osy ~= nsy) then
      -- In new sector, move us to the right sector
      region.rem_sector(x, y)
      region.add_sector(nx, ny)
      -- and draw us
      -- replace with love2d integration
      -- esdl_server.set_unit(style, colour, nx, ny)
   end
   return nx,ny
end

function this_unit.tick()
   x,y = move(x, y)
end

function this_unit.zap()  -- The unit has been zapped and will die
   -- replace with love2d integration
   -- esdl_server.set_unit("explosion", colour, x, y)
   region.rem_sector(x, y)
end

return this_unit                    -- Return the unit table