--
-- What macro means in the context of brood war?
--
local utils = require("torchcraft.utils")
local tools = require("spaceboard.tools")

local macro = {}

local powering = true

local spawning_overlord = false

local spawning_pool = 0

local hydralisk_den = 0

local queen_nest = 0

local evolution_chamber = 0

local spire = 0

local has_spool = false

local has_hden = false

local has_qnest = false

local has_echamber = false

local has_spire = false

-- Early, Make/defend a play & send colonies to one or two bases.
local early_stage = true
-- Middle, Core units, make/defend pressure & take a base.
local middle_stage = false
-- Late, Matured core units, multi-pronged tactics & take many bases.
local late_stage = false
-- Final, The watcher observes, the fog collapses an event resolves.
local final_stage = false

function macro.manage_economy(actions, tc)
    -- What exactly is macro, anyway? 
    -- this interpretation includes 'powering'.
    -- powering is when computer switch to primarily
    -- economics, making drones and new gas patches.
    local workers = {}
    -- Spawn more overlords!
    local overlords = {}
    -- macro colonies 
    local colonies = {}
    colonies[1] = 0
    colonies[2] = 0
    colonies[3] = 0
    colonies[4] = 0
    colonies[5] = 0
    colonies[6] = 0
    -- Timing to expand is key and can be extracted
    -- from datasets of competitive players.
    local buildings = {}
    -- Set your units into 4 groups, collapse each on
    -- different sides of the enemy for maximum effectiveness.
    local offence = {}
    -- Defense powerful but immobile, offence mobile but weak
    local defence = {}
    
    for uid, ut in pairs(tc.state.units_myself) do
        if tc:isbuilding(ut.type) then
            -- tests stuff within buildings: train, upgrade, rally!
            if ut.type == tc.unittypes.Zerg_Spawning_Pool then
                if has_spool == false then
                    has_spool = true
                end
            end
            if ut.type == tc.unittypes.Zerg_Hatchery then
                if powering == true then
                    table.insert(actions,
                    tc.command(tc.command_unit, uid, tc.cmd.Train,
                    0, 0, 0, tc.unittypes.Zerg_Drone))
                end
                if spawning_overlord == true and powering == false then
                    table.insert(actions,
                    tc.command(tc.command_unit, uid, tc.cmd.Train,
                    0, 0, 0, tc.unittypes.Zerg_Overlord))
                    spawning_overlord = false
                end
            end
        elseif ut.type == tc.unittypes.Zerg_Overlord then
            table.insert(overlords, uid)
        elseif tc:isworker(ut.type) then        
            table.insert(workers, uid)
            if has_spool == false and tc.state.resources_myself.ore >= 200
                and tc.state.frame_from_bwapi - spawning_pool > 190 then
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
                    print('starting location: x ' .. pos[1] .. ' y ' .. pos[2])
                end
            elseif tc.state.resources_myself.ore >= 300 
                and tc.state.frame_from_bwapi - colonies[2] > 200 then
                colonies[2] = tc.state.frame_from_bwapi
                if not utils.is_in(ut.order,
                    tc.command2order[tc.unitcommandtypes.Build])
                    and not utils.is_in(ut.order,
                    tc.command2order[tc.unitcommandtypes.Right_Click_Position]) then
                    table.insert(actions,
                    tc.command(tc.command_unit, uid,
                    tc.cmd.Build, -1,
                    56, 152, tc.unittypes.Zerg_Hatchery))
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
    -- 
    if #workers == 9 and powering == true then
        spawning_overlord = true
        powering = false
    end
    -- 
    if #overlords >= 2 and powering == false then
        powering = true
    end
    -- 
    if #workers >= 13 then
        powering = false
    end
    -- So long and thanks for all the fish!
    return actions
end

return macro
