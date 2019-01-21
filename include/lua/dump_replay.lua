--[[
-- This is a replay dumper test / example. Simply set your starcraft to open a
-- replay. Then, run
--  th dump_replay -t $SC_IP
]]
require 'torch'
torch.setdefaulttensortype('torch.FloatTensor')
require 'sys'
local lapp = require 'pl.lapp'
local params = lapp [[
Tests replay dumping / reloading
-t,--hostname       (default "")    Give hostname / ip pointing to VM
-p,--port           (default 11111) Port for torchcraft. Do 0 to grab vm from cloud
-o,--out            (default "/tmp") Where to save the replay
]]

local skip_frames = 3
local port = params.port
local hostname = params.hostname or ""
print("hostname:", hostname)
print("port:", port)

local torch = require 'torch'
local threads = require 'threads'

local p = require 'pl.path'
local replayer = require 'torchcraft.replayer'
local tc = require 'torchcraft'

sys.sleep(5.0)

tc:init(params.hostname, params.port)

print("Doing replay...")
local map = tc:connect(params.hostname, params.port)
assert(tc.state.replay, "This game isn't a replay")
tc:send({table.concat({
  tc.command(tc.set_speed, 0), tc.command(tc.set_gui, 0),
  tc.command(tc.set_combine_frames, skip_frames),
  tc.command(tc.set_frameskip, 1000), tc.command(tc.set_log, 0),
}, ":")})
tc:receive()
map = tc.state

local game = replayer.newReplayer()
game:setMap(map)
print("Dumping "..map.map_name)

local is_ok, err = false, nil
while not tc.state.game_ended do
  is_ok, err = pcall(function () return tc:receive() end)
  if not is_ok then break end
  game:push(tc.state.frame)
end

print("Game ended....")
local savePath = params.out.."/"..map.map_name..".tcr"
if not is_ok then
  print("Encountered an error: ", err)
else
  print("Saving to " .. savePath)
  game:setKeyFrame(-1)
  game:save(savePath, true)
  print("Done dumping replay")
  tc:send({table.concat({tc.command(tc.quit)}, ":")})
end

tc:close()
print("BEAM me up Erlang")
