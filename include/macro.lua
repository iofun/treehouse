--
-- What macro means in the context of brood war?
--
local utils = require("torchcraft.utils")
local tools = require("blackboard.tools")

local macro = {}

local spawning_pool = 0

local powering = true


function macro.manage_economy(actions, tc)

	local workers = {}

	local buildings = {}

	local offence = {}

	local defence = {}

    for uid, ut in pairs(tc.state.units_myself) do
		if tc:isbuilding(ut.type) then

			-- tests stuff within buildings: train, upgrade, rally!
			
			if ut.type == tc.unittypes.Zerg_Hatchery then
						
				if powering == true then
					table.insert(actions,
					tc.command(tc.command_unit, uid, tc.cmd.Train,
					0, 0, 0, tc.unittypes.Zerg_Drone))
				else
					print('more than 13?')
				end
                if #workers == 9 and powering == true then
					tc.command(tc.command_unit, uid, tc.cmd.Train,
					0, 0, 0, tc.unittypes.Zerg_Overlord))
                end
			end
		elseif tc:isworker(ut.type) then		
			table.insert(workers, uid)
			if tc.state.resources_myself.ore >= 180
				and tc.state.frame_from_bwapi - spawning_pool > 192 then
				-- tests building		
				spawning_pool = tc.state.frame_from_bwapi
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
				if not utils.is_in(ut.order,
					  tc.command2order[tc.unitcommandtypes.Gather])
					  and not utils.is_in(ut.order,
					  tc.command2order[tc.unitcommandtypes.Build])
					  and not utils.is_in(ut.order,
					  tc.command2order[tc.unitcommandtypes.Right_Click_Position]) then
					-- avoid spamming the order is the unit is already
					-- following the right order or building!
					-- currently we need to learn how to get vespene gas
					local target = tools.get_closest(ut.position,
						tc:filter_type(tc.state.units_neutral,
							{tc.unittypes.Resource_Mineral_Field,
							 tc.unittypes.Resource_Mineral_Field_Type_1,
							 tc.unittypes.Resource_Mineral_Field_Type_3,
							 tc.unittypes.Resource_Mineral_Field_Type_2,
							 tc.unittypes.Resorce_Mineral_Field_Type_5,
							 tc.unittypes.Resorce_Mineral_Field_Type_4,}))
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
	
	print('102 ' .. #workers)
	
	if #workers >= 13 then
		powering = false
	else
		powering = true
	end
	
	return actions
end

return macro
