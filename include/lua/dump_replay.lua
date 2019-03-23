#!/usr/bin/env luajit
--[[
-- This is a replay dumper. Simply set your starcraft to open a replay.
-- Then, run
--  th dump_replay -t $SC_IP
]]
require("torch")
torch.setdefaulttensortype("torch.FloatTensor")
require("sys")
local replayer = require("torchcraft.replayer")
local argparse = require("argparse")
local socket = require("socket")
local uuid = require("uuid")
local tc = require("torchcraft")
-- Gen random seed
uuid.randomseed(socket.gettime()*10000)
-- Spawn execution uuid
local spawn_uuid = uuid()
print("Starting replay dumper "..spawn_uuid)
-- CLI argument parser
local parser = argparse() {
    name = "dump_replay",
    description = "Simply set your StarCraft to dump a replay.",
    epilog = "(lua prototype)"
}
parser:option("-t --hostname", "Give hostname / ip pointing to VM", "127.0.0.1")
parser:option("-p --port", "Port for TorchCraft", 11111)
parser:option("-o --out", "Where to save the replay", "/tmp")
-- Parse your arguments
local args = parser:parse()
local hostname = args['hostname']
local port = args['port']
local out = args['out']
-- Skip BWAPI frames
local skip_frames = 3
-- Give some time to load the replay
sys.sleep(5.0)
tc:init(hostname, port)
print("Doing replay...")
local map = tc:connect(hostname, port)
assert(tc.state.replay, "This game isn't a replay")
tc:send({table.concat({
  tc.command(tc.set_speed, 0), tc.command(tc.set_gui, 0),
  tc.command(tc.set_combine_frames, skip_frames),
  tc.command(tc.set_frameskip, 1000), tc.command(tc.set_log, 0),
}, ":")})
tc:receive()
map = tc.state
-- Game this replay
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
local savePath = out.."/"..map.map_name..".tcr"
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
