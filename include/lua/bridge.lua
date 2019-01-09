#!/usr/bin/env luajit
--
-- Bridge between TorchCraft 1.3 (lua prototype)
--
local argparse = require("argparse")
local socket = require("socket")
local uuid = require("uuid")
require("torch")
torch.setdefaulttensortype('torch.FloatTensor')
require("sys")
local tc = require("torchcraft")
local utils = require("torchcraft.utils")
local tools = require("xelnaga.tools")
-- Debug can take values 0, 1, 2 (from no output to most verbose) 
local DEBUG = 0 
tc.DEBUG = DEBUG
-- gen random seed
uuid.randomseed(socket.gettime()*10000)
-- Spawn UUID
local spawn_uuid = uuid()
-- CLI argument parser
local parser = argparse() {
    name = "bridge",
    description = "Bridge between StarCraft and TorchCraft",
    epilog = "(lua prototype)"
}
parser:option("-t --hostname", "Give hostname/ip to VM", "127.0.0.1")
parser:option("-p --port", "Port for TorchCraft", 11111)
-- Your system variables
local restarts = -1
-- Skip bwapi frames
local skip_frames = 7
-- Parse your arguments
local args = parser:parse()
local hostname = args['hostname']
local port = args['port'] 
-- Do your main loop 
while restarts < 10 do
    restarts = restarts + 1
    tc:init(hostname, port)
    local frames_in_battle = 1
    local nloop = 1
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
    local built_spool = 0
    local tm = torch.Timer()
    -- game loop
    while not tc.state.game_ended do
        -- reset timer
        tm:reset()
        -- receive update from game engine
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
                            and tc.state.frame_from_bwapi - built_spool > 240 then -- tests building
                            built_spool = tc.state.frame_from_bwapi
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
                    restarts = restarts + 1
                end
            end
        end
        -- if debug make some noise!
        if DEBUG > 1 then
            print("")
            print("Sending actions:")
            print(actions)
        end
        tc:send({table.concat(actions, ':')})
    end
    tc:close()
    collectgarbage()
    sys.sleep(0.5)
    collectgarbage()
end
print("So Long, and Thanks for All the Fish!")
