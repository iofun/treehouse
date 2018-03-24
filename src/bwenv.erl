-module(bwenv).

-export([start/3,start_link/3]).
-export([init/3]).

%% bwapi init approximation functions (=
-export([game_type/0,
         net_mode/0,
         active_tile_array/0,
         mini_tile_flags/0,
         map_tile_array/0,
         tile_set_map/0,
         trigger_vectors/0,
         save_game_file/0,
         current_map_file/0,
         replay_header/0,
         frame_skip/0,
         latency_frames/0,
         screen_x/0,
         screen_y/0,
         move_to_x/0,
         move_to_y/0,
         vissible_units/0,
         hidden_units/0,
         resource_count/0,
         gather_queue_count/0,
         next_gatherer/0,
         hit_points/0,
         move_target/0,
         current_direction/0,
         current_speed/0,
         %% setters
         set_local_speed/0,
         set_vision/0,
         set_frame_skip/0,
         %% checkers
         has_nuke/0,
         in_replay/0,
         is_game_paused/0,
         is_being_gathered/0,
         is_carrying_gas/0,
         is_carrying_minerals/0,
         is_moving/0,
         is_accelerating/0,
         is_under_storm/0,
         is_starting_attack/0,
         is_attacking/0,
         is_attack_frame/0,
         is_stuck/0,
         is_completed/0,
         is_burrowed/0,
         is_cloacked/0,
         is_gathering/0,
         is_lifted/0,
         is_powered/0,
         is_interruptible/0,
         is_hallucination/0,
         is_visible/0,
         is_detected/0,
         is_being_healed/0,
         %% getters
         get_mouse_position/0,
         get_hit_points/0,
         get_resource_group/0,
         get_nydus_exit/0,
         get_build_unit/0,
         get_addon/0,
         get_rally_position/0,
         get_rally_unit/0,
         get_remove_timer/0,
         get_defense_matrix_points/0,
         get_defense_matrix_timer/0,
         get_spider_mine_count/0,
         get_remaining_upgrade_time/0,
         get_remaining_research_time/0,
         get_tech/0,
         get_upgrade/0,
         get_remaining_train_time/0,
         get_player/0,
         get_order/0,
         get_order_timer/0,
         get_velocity/0,
         get_angle/0,
         get_target_position/0,
         get_energy/0,
         get_ground_weapon_cooldown/0,
         get_acid_spore_count/0,
         get_ensnare_timer/0,
         get_stim_timer/0,
         get_air_weapon_cooldown/0,
         get_spell_cooldown/0,
         get_order_target/0,
         get_order_target_position/0,
         get_shields/0,
         get_type/0,
         get_transport/0,
         get_hatchery/0,
         get_kill_count/0,
         get_last_attacking_player/0,
         get_training_queue/0]).

-export([lua_do/2,gc/1]).    % LuaLang commands

%% Management API.

start(X, Y, State) ->
    proc_lib:start(?MODULE, init, [X,Y,State]).

start_link(X, Y, State) ->
    proc_lib:start_link(?MODULE, init, [X,Y,State]).

%% init our bwapi environment approximation
game_type() ->
    Message = "game_type",
    lager:warning("execute bwapi ~p function \n", [Message]).

net_mode() ->
    Message = "net_mode",
    lager:warning("execute bwapi ~p function \n", [Message]).

active_tile_array() -> 
    Message = "active_tile_array",
    lager:warning("execute bwapi ~p function \n", [Message]).

mini_tile_flags() -> 
    Message = "mini_tile_flags",
    lager:warning("execute bwapi ~p function \n", [Message]).

tile_set_map() ->
    Message = "tile_set_map",
    lager:warning("execute bwapi ~p function \n", [Message]).

map_tile_array() -> 
    Message = "map_tile_array",
    lager:warning("execute bwapi ~p function \n", [Message]).

trigger_vectors() ->
    Message = "trigger_vectors",
    lager:warning("execute bwapi ~p function \n", [Message]).

save_game_file() ->
    Message = "save_game_file",
    lager:warning("execute bwapi ~p function \n", [Message]).

current_map_file() ->
    Message = "current_map_file",
    lager:warning("execute bwapi ~p function \n", [Message]).

replay_header() ->
    Message = "replay_header",
    lager:warning("execute bwapi ~p function \n", [Message]).

frame_skip() -> 
    Message = "frame_skip",
    lager:warning("execute bwapi ~p function \n", [Message]).

latency_frames() -> 
    Message = "latency_frames",
    lager:warning("execute bwapi ~p function \n", [Message]).

screen_x() -> 
    Message = "screen_x",
    lager:warning("execute bwapi ~p function \n", [Message]).

screen_y() -> 
    Message = "screen_y",
    lager:warning("execute bwapi ~p function \n", [Message]).

move_to_x() ->
    Message = "move_to_x",
    lager:warning("execute bwapi ~p function \n", [Message]).

move_to_y() -> 
    Message = "move_to_y",
    lager:warning("execute bwapi ~p function \n", [Message]).

vissible_units() ->  
    Message = "vissible_units",
    lager:warning("execute bwapi ~p function \n", [Message]).

hidden_units() -> 
    Message = "hidden_units",
    lager:warning("execute bwapi ~p function \n", [Message]).

resource_count() -> 
    Message = "resource_count",
    lager:warning("execute bwapi ~p function \n", [Message]).

gather_queue_count() -> 
    Message = "gather_queue_count",
    lager:warning("execute bwapi ~p function \n", [Message]).

next_gatherer() -> 
    Message = "next_gatherer",
    lager:warning("execute bwapi ~p function \n", [Message]).

hit_points() -> 
    Message = "hit_points",
    lager:warning("execute bwapi ~p function \n", [Message]).

move_target() -> 
    Message = "move_target",
    lager:warning("execute bwapi ~p function \n", [Message]).

current_direction() -> 
    Message = "current_direction",
    lager:warning("execute bwapi ~p function \n", [Message]).

current_speed() ->
    Message = "current_speed",
    lager:warning("execute bwapi ~p function \n", [Message]).

% explicit setters
set_local_speed() ->
    Message = "set_local_speed",
    lager:warning("execute bwapi ~p function \n", [Message]).

set_vision() ->
    Message = "set_vision",
    lager:warning("execute bwapi ~p function \n", [Message]).

set_frame_skip() ->
    Message = "set_frame_skip",
    lager:warning("execute bwapi ~p function \n", [Message]).

% checkers
has_nuke() -> 
    Message = "has_nuke",
    lager:warning("execute bwapi ~p function \n", [Message]).

in_replay() -> 
    Message = "in_replay",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_game_paused() -> 
    Message = "is_game_paused",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_being_gathered() -> 
    Message = "is_being_gathered",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_carrying_gas() -> 
    Message = "is_carrying_gas",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_carrying_minerals() -> 
    Message = "is_carrying_minerals",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_moving() -> 
    Message = "is_moving",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_accelerating() -> 
    Message = "is_accelerating",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_under_storm() -> 
    Message = "is_under_storm",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_starting_attack() -> 
    Message = "is_starting_attack",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_attacking() -> 
    Message = "is_attacking",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_attack_frame() -> 
    Message = "is_attack_frame",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_stuck() -> 
    Message = "is_stuck",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_completed() -> 
    Message = "is_completed",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_burrowed() -> 
    Message = "is_burrowed",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_cloacked() -> 
    Message = "is_cloacked",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_gathering() -> 
    Message = "is_gathering",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_lifted() -> 
    Message = "is_lifted",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_powered() -> 
    Message = "is_powered",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_interruptible() -> 
    Message = "is_interruptible",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_hallucination() -> 
    Message = "is_hallucination",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_visible() -> 
    Message = "is_visible",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_detected() -> 
    Message = "is_detected",
    lager:warning("execute bwapi ~p function \n", [Message]).

is_being_healed() -> 
    Message = "is_being_healed",
    lager:warning("execute bwapi ~p function \n", [Message]).

% getters
get_mouse_position() -> 
    Message = "is_mouse_position",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_hit_points() -> 
    Message = "get_hit_points",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_resource_group() -> 
    Message = "get_resource_group",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_nydus_exit() -> 
    Message = "get_nydus_exit",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_build_unit() -> 
    Message = "get_build_unit",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_addon() -> 
    Message = "get_addon",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_rally_position() -> 
    Message = "get_rally_position",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_rally_unit() -> 
    Message = "get_rally_unit",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_remove_timer() -> 
    Message = "get_remove_timer",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_defense_matrix_points() -> 
    Message = "get_defense_matrix_points",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_defense_matrix_timer() -> 
    Message = "get_defense_matrix_timer",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_spider_mine_count() -> 
    Message = "get_spider_mine_count",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_remaining_upgrade_time() -> 
    Message = "get_remaining_upgrade_time",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_remaining_research_time() -> 
    Message = "get_remaining_research_time",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_tech() -> 
    Message = "get_tech",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_upgrade() -> 
    Message = "get_upgrade",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_remaining_train_time() -> 
    Message = "get_remaining_train_time",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_player() -> 
    Message = "get_player",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_order() -> 
    Message = "get_order",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_order_timer() -> 
    Message = "get_order_timer",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_velocity() -> 
    Message = "get_velocity",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_angle() -> 
    Message = "get_angle",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_target_position() -> 
    Message = "get_target_position",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_energy() -> 
    Message = "get_energy",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_ground_weapon_cooldown() -> 
    Message = "get_ground_weapon_cooldown",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_acid_spore_count() -> 
    Message = "get_acid_spore_count",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_ensnare_timer() -> 
    Message = "get_ensnare_timer",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_stim_timer() -> 
    Message = "get_stim_timer",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_air_weapon_cooldown() -> 
    Message = "get_air_weapon_cooldown",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_spell_cooldown() -> 
    Message = "get_spell_cooldown",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_order_target() -> 
    Message = "get_order_target",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_order_target_position() -> 
    Message = "get_order_target_position",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_shields() -> 
    Message = "get_shields",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_type() -> 
    Message = "get_type",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_transport() -> 
    Message = "get_transport",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_hatchery() -> 
    Message = "get_hatchery",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_kill_count() -> 
    Message = "get_kill_count",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_last_attacking_player() -> 
    Message = "get_last_attacking_player",
    lager:warning("execute bwapi ~p function \n", [Message]).

get_training_queue() -> 
    Message = "get_training_queue",
    lager:warning("execute bwapi ~p function \n", [Message]).

% "do" any Lua command

lua_do(Unit, Command) ->
    call(Unit, {lua_do, Command}).

gc(Unit) ->
    call(Unit, gc).

%% Main loop.

init(X, Y, State0) ->
    % Put us in some region
    region:add_sector(X, Y, self()),
    {_,State1} = luerl:call_function([this_unit,start], [], State0),
    {_,State2} = luerl:call_function([this_unit,set_position], [X,Y], State1),
    {_,State3} = luerl:call_function([this_unit,set_speed], [0,0], State2),
    proc_lib:init_ack({ok,self()}),
    % Start with dummy tick ref
    loop(State3, infinity, make_ref(), 0).

%% loop(LuerlState, Tick, TickRef, TickCount) -> no_return().

loop(State0, Tick, Tref, Tc) ->
    receive
    {call,From,get_position} ->
        {[X,Y],State1} = luerl:call_function([this_unit,get_position], [], State0),
        reply(From, {X,Y}),
        loop(State1, Tick, Tref, Tc);
    {cast,From,{set_position,X,Y}} ->
        %%  logging unused variable!
        lager:warning("set_position From? ~p \n", [From]),
        {_,State1} = luerl:call_function([this_unit,set_position],
                      [float(X),float(Y)], State0),
        loop(State1, Tick, Tref, Tc);
    {call,From,get_speed} ->
        {[Dx,Dy],State1} = luerl:call_function([this_unit,get_speed], [], State0),
        reply(From, {Dx,Dy}),
        loop(State1, Tick, Tref, Tc);
    {cast,From,{set_speed,Dx,Dy}} ->
        %%  logging unused variable!
        lager:warning("set_speed From? ~p \n", [From]),
        {_,State1} = luerl:call_function([this_unit,set_speed],
                      [float(Dx),float(Dy)], State0),
        loop(State1, Tick, Tref, Tc);
    {call,From,{lua_do,Command}} ->     %"do" any Lua command
        {Rs,State1} = luerl:do(Command, State0),
        reply(From, {ok,Rs}),
        loop(State1, Tick, Tref, Tc);
    {call,From,gc} ->           %Gc the luerl state
        State1 = luerl:gc(State0),
        reply(From, ok),
        loop(State1, Tick, Tref, Tc)
    end.

