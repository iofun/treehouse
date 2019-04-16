#!/usr/bin/env luajit
--[[
-- This is a replay runner. Just, run
--  th run_replay -r $replay_id
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
print("Starting replayer "..spawn_uuid)
-- CLI argument parser
local parser = argparse() {
    name = "run_replay",
    description = "Run a StarCraft replay.",
    epilog = "(lua prototype)"
}
parser:option("-r --replay", "Give replay name, uuid or hash", 42)
parser:option("-o --out", "Where the replays are saved", "/tmp")
-- Parse your arguments
local args = parser:parse()
local replay = args['replay']
local out = args['out']

local savePath = out.."/"..replay..".tcr"
print(savePath)
local savedRep = replayer.loadReplayer(savePath)

walkmap, heightmap, buildmap, startloc = savedRep:getMap()

function checkMap(ret, desc, outname)
  print("Checking "..desc.." from replay!")
  local mf = io.open(outname, 'w')
  local max = ret:max()
  mf:write("P2 " .. walkmap:size(2) .. " " .. walkmap:size(1) .. " " .. max .. "\n")
  for y = 1, ret:size(1) do
    for x = 1, ret:size(2) do
      mf:write(ret[y][x] .. " ")
    end
    mf:write('\n')
  end
end

checkMap(walkmap, "Walkability", out.."/walkmap.pgm")
checkMap(heightmap, "Ground Height", out.."/heightmap.pgm")
checkMap(buildmap, "Buildability", out.."/buildmap.pgm")

for i=1, savedRep:getNumFrames() do
  local f = savedRep:getFrame(i)
  --local units = f:getUnits()
  local resources = f:toTable()
  --print(units)
  print(resources)
end
