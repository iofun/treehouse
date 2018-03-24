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
save_game_file() -> 
current_map_file() ->
replay_header() -> 
frame_skip() -> 
latency_frames() -> 
screen_x() -> 
screen_y() -> 
move_to_x() -> 
move_to_y() -> 
vissible_units() ->  
hidden_units() -> 
resource_count() -> 
gather_queue_count() -> 
next_gatherer() -> 
hit_points() -> 
move_target() -> 
current_direction() -> 
current_speed() ->
% explicit setters
set_local_speed() -> 
set_vision() -> 
set_frame_skip() ->
% checkers
has_nuke() -> 
in_replay() -> 
is_game_paused() ->  
is_being_gathered() -> 
is_carrying_gas() -> 
is_carrying_minerals() -> 
is_moving() -> 
is_accelerating() -> 
is_under_storm() -> 
is_starting_attack() -> 
is_attacking() -> 
is_attack_frame() -> 
is_stuck() -> 
is_completed() -> 
is_burrowed() -> 
is_cloacked() -> 
is_gathering() -> 
is_lifted() -> 
is_powered() -> 
is_interruptible() -> 
is_hallucination() -> 
is_visible() -> 
is_detected() -> 
is_being_healed() -> 
% getters
get_mouse_position() -> 
get_hit_points() -> 
get_resource_group() -> 
get_nydus_exit() -> 
get_build_unit() -> 
get_addon() -> 
get_rally_position() -> 
get_rally_unit() -> 
get_remove_timer() -> 
get_defense_matrix_points() -> 
get_defense_matrix_timer() -> 
get_spider_mine_count() -> 
get_remaining_upgrade_time() -> 
get_remaining_research_time() -> 
get_tech() -> 
get_upgrade() -> 
get_remaining_train_time() -> 
get_player() -> 
get_order() -> 
get_order_timer() -> 
get_velocity() -> 
get_angle() -> 
get_target_position() -> 
get_energy() -> 
get_ground_weapon_cooldown() -> 
get_acid_spore_count() -> 
get_ensnare_timer() -> 
get_stim_timer() -> 
get_air_weapon_cooldown() -> 
get_spell_cooldown() -> 
get_order_target() -> 
get_order_target_position() -> 
get_shields() -> 
get_type() -> 
get_transport() -> 
get_hatchery() -> 
get_kill_count() -> 
get_last_attacking_player() -> 
get_training_queue() -> 

lua_do(Unit, Command) ->             % "do" any Lua command
    call(Unit, {lua_do, Command}).

gc(Unit) ->
    call(Unit, gc).

%% Main loop.

init(X, Y, State0) ->
    region:add_sector(X, Y, self()),       % Put us in some region
    {_,State1} = luerl:call_function([this_unit,start], [], State0),
    {_,State2} = luerl:call_function([this_unit,set_position], [X,Y], State1),
    {_,State3} = luerl:call_function([this_unit,set_speed], [0,0], State2),
    proc_lib:init_ack({ok,self()}),
    loop(State3, infinity, make_ref(), 0). % Start with dummy tick ref

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

