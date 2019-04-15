#!/usr/bin/env luajit
--
-- Bridge between StarCraft 1.16.1 and TorchCraft 1.3
--
local argparse = require("argparse")
local socket = require("socket")
local uuid = require("uuid")
require("torch")
require("sys")
local tc = require("torchcraft")
local utils = require("torchcraft.utils")
local tools = require("blackboard.tools")

-- Set default float tensor type
torch.setdefaulttensortype('torch.FloatTensor')
-- Debug can take values 0, 1, 2 (from no output to most verbose)
tc.DEBUG = 0
-- Gen random seed
uuid.randomseed(socket.gettime()*10000)
-- Spawn UUID
local spawn_uuid = uuid()
print("Starting bridge 1.3 " .. spawn_uuid)
-- CLI argument parser
local parser = argparse() {
    name = "bridge",
    description = "Bridge between StarCraft 1.16.1 and TorchCraft 1.3",
    epilog = "(luajit prototype)"
}
parser:option("-t --hostname", "Give hostname/ip to VM", "127.0.0.1")
parser:option("-p --port", "Port for TorchCraft", 11111)

-- Bridge system variables
local restarts = -1
-- Skip bwapi frames
local skip_frames = 7
-- Parse your arguments
local args = parser:parse()
local hostname = args['hostname']
local port = args['port'] 

-- Do your main loop 
while restarts < 5 do
    restarts = restarts + 1
    tc:init(hostname, port)
    local loops = 1
    local update = tc:connect(port)
    if tc.DEBUG > 1 then
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
    tools.this_is()
    -- game loop
    while not tc.state.game_ended do
        -- reset timer
        tm:reset()
        -- receive update from game engine
        update = tc:receive()
        if tc.DEBUG > 1 then
            print('Received update: ', update)
        end
        loops = loops + 1
        local actions = {}
        
        if tc.state.battle_frame_count % skip_frames == 0 then
            for uid, ut in pairs(tc.state.units_myself) do
				if tc:isbuilding(ut.type) then

					-- tests production
					
					if ut.type == tc.unittypes.Zerg_Hatchery then
						
						table.insert(actions,
						tc.command(tc.command_unit, uid, tc.cmd.Train,
						0, 0, 0, tc.unittypes.Zerg_Drone))
						
					end
				elseif tc:isworker(ut.type) then
					if tc.state.resources_myself.ore >= 190
						and tc.state.frame_from_bwapi - built_spool > 200 then
						
						-- tests building
						
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
							pos[1], pos[2] + 16, tc.unittypes.Zerg_Spawning_Pool))
						end
					else
						-- tests gathering
						-- TBD: HOW WE GAS?
						if not utils.is_in(ut.order,
							  tc.command2order[tc.unitcommandtypes.Gather])
							  and not utils.is_in(ut.order,
							  tc.command2order[tc.unitcommandtypes.Build])
							  and not utils.is_in(ut.order,
							  tc.command2order[tc.unitcommandtypes.Right_Click_Position]) then
							-- avoid spamming the order is the unit is already
							-- following the right order or building!
							local target = tools.get_closest(ut.position,
								tc:filter_type(tc.state.units_neutral,
									{tc.unittypes.Resource_Mineral_Field,
									 tc.unittypes.Resource_Mineral_Field_Type_2,
									 tc.unittypes.Resource_Mineral_Field_Type_3,
									 tc.unittypes.Resorce_Mineral_Field_Type_4,
									 tc.unittypes.Resorce_Mineral_Field_Type_5,}))
							if target ~= nil then
								table.insert(actions,
								tc.command(tc.command_unit_protected, uid,
								tc.cmd.Right_Click_Unit, target))
							end
						end
					end
				else
					-- attacks closest
					local target = tools.get_closest(ut.position,
											   tc.state.units_enemy)
					if target ~= nil then
						table.insert(actions,
						tc.command(tc.command_unit_protected, uid,
						tc.cmd.Attack_Unit, target))
					end
				end
			end
        elseif tc.state.game_ended then
            break
        else
            -- skip frame do nothing
        end
        -- if debug make some noise!
        if tc.DEBUG > 1 then
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
