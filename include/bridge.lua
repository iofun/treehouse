#!/usr/bin/env luajit
--
-- new old th bridge.lua [-t $hostname] [-p $port]
--
local argparse = require("argparse")
local socket = require("socket")
local uuid = require("uuid")
-- gen random seed
uuid.randomseed(socket.gettime()*10000)
-- Spawn UUID
local spawn_uuid = uuid()
-- Debug mode
local DEBUG = 0 -- can take values 0, 1, 2 (from no output to most verbose)
require 'torch'
torch.setdefaulttensortype('torch.FloatTensor')
require 'sys'
local skip_frames = 7

local parser = argparse() {
    name = "bridge",
    description = "",
    epilog = ""
}
parser:option("-t --hostname", "Give hostname / ip pointing to SCI-F", "")
parser:option("-p --port", "Port for TorchCraft", 11111)

local tc = require 'torchcraft'
tc.DEBUG = DEBUG
local utils = require 'torchcraft.utils'

-- Parse your arguments
local args = parser:parse()
local hostname = args['hostname']
local port = args['port'] 

local function get_closest(position, unitsTable)
    local min_d = 1E30
    local closest_uid = nil
    for uid, ut in pairs(unitsTable) do
        local tmp_d = utils.distance(position, ut['position'])
        if tmp_d < min_d then
            min_d = tmp_d
            closest_uid = uid
        end
    end
    return closest_uid
end

local battles_won = 0
local battles_game = 0
local total_battles = 0

-- no ',' accepted in map names!
-- All paths must be relative to C:/StarCraft
local maps = {'Maps/BroodWar/Aztec 2.1_iCCup.scx',}

local nrestarts = -1

while total_battles < 40 do

    local frames_in_battle = 1
    local nloop = 1
    battles_won = 0
    battles_game = 0
    nrestarts = nrestarts + 1

    tc:init(hostname, port)
    local update = tc:connect(port)
    if DEBUG > 1 then
        print('Received init: ', update)
    end
    assert(tc.state.replay == false)

    -- first message to BWAPI's side is setting up variables
    local setup = {
        tc.command(tc.set_speed, 0), tc.command(tc.set_gui, 1),
        tc.command(tc.set_cmd_optim, 1),
    }
    tc:send({table.concat(setup, ':')})

    local built_barracks = 0

    local tm = torch.Timer()
    while not tc.state.game_ended do
        --progress:add('Loop', nloop, '%5d')
        --progress:add('FPS', 1 / tm:time().real, '%5d')
        --progress:add('WR', battles_won / (battles_game+1E-6), '%1.3f')
        --progress:add('#Wins', battles_won, '%4d')
        --progress:add('#Bttls', battles_game, '%4d')
        --progress:add('Tot Bttls', total_battles, '%4d')
        --progress:push()
        tm:reset()

        update = tc:receive()
        if DEBUG > 1 then
            print('Received update: ', update)
        end

        nloop = nloop + 1
        local actions = {}
        if tc.state.game_ended then
            break
        else
            if tc.state.battle_frame_count % skip_frames == 0 then
                for uid, ut in pairs(tc.state.units_myself) do
                    if tc:isbuilding(ut.type) then -- tests production
                        if ut.type == tc.unittypes.Terran_Barracks then
                            table.insert(actions,
                            tc.command(tc.command_unit, uid, tc.cmd.Train,
                            tc.unittypes.Terran_Marine))
                        end
                    elseif tc:isworker(ut.type) then
                        if tc.state.resources_myself.ore >= 150
                            and tc.state.frame_from_bwapi - built_barracks > 240 then -- tests building
                            built_barracks = tc.state.frame_from_bwapi
                            local _, pos = next(tc:filter_type(
                            tc.state.units_myself,
                            {tc.unittypes.Zerg_Hatchery}))
                            if pos ~= nil then pos = pos.position end
                            if pos ~= nil and not utils.is_in(ut.order,
                                tc.command2order[tc.unitcommandtypes.Build])
                                and not utils.is_in(ut.order,
                                tc.command2order[tc.unitcommandtypes.Right_Click_Position]) then
                                table.insert(actions,
                                tc.command(tc.command_unit, uid,
                                tc.cmd.Build, -1,
                                pos[1], pos[2] + 8, tc.unittypes.Zerg_Spawning_Pool))
                            end
                        else -- tests gathering
                            if not utils.is_in(ut.order,
                                  tc.command2order[tc.unitcommandtypes.Gather])
                                  and not utils.is_in(ut.order,
                                  tc.command2order[tc.unitcommandtypes.Build])
                                  and not utils.is_in(ut.order,
                                  tc.command2order[tc.unitcommandtypes.Right_Click_Position]) then
                                -- avoid spamming the order is the unit is already
                                -- following the right order or building!
                                local target = get_closest(ut.position,
                                    tc:filter_type(tc.state.units_neutral,
                                        {tc.unittypes.Resource_Mineral_Field,
                                         tc.unittypes.Resource_Mineral_Field_Type_2,
                                         tc.unittypes.Resource_Mineral_Field_Type_3}))
                                if target ~= nil then
                                    table.insert(actions,
                                    tc.command(tc.command_unit_protected, uid,
                                    tc.cmd.Right_Click_Unit, target))
                                end
                            end
                        end
                    else -- attacks closest
                        local target = get_closest(ut.position,
                                                   tc.state.units_enemy)
                        if target ~= nil then
                            table.insert(actions,
                            tc.command(tc.command_unit_protected, uid,
                            tc.cmd.Attack_Unit, target))
                        end
                    end
                end
                if frames_in_battle > 2*60*24 then -- quit after ~ 2 hours
                    actions = {tc.command(tc.quit)}
                    nrestarts = nrestarts + 1
                end
                --progress:pop()
            end
        end

        if DEBUG > 1 then
            print("")
            print("Sending actions:")
            print(actions)
        end
        tc:send({table.concat(actions, ':')})
    end
    tc:close()
    sys.sleep(0.5)
    --progress:reset()
    print("an orchestral interlude")
    collectgarbage()
    collectgarbage()
end
print("")
