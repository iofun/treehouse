-module(ship).

-export([start/3,start_link/3]).
-export([init/3]).
-export([set_tick/2,get_pos/1,set_pos/3,get_speed/1,set_speed/3,zap/1]).
-export([get_state/1,get_tc/1]).
-export([set_ship/2,lua_do/2,gc/1]).			%Lua commands

%% Management API.

start(X, Y, St) ->
    proc_lib:start(?MODULE, init, [X,Y,St]).

start_link(X, Y, St) ->
    proc_lib:start_link(?MODULE, init, [X,Y,St]).

%% User API.

set_tick(Ship, Tick) ->
    cast(Ship, {set_tick,Tick}).

get_pos(Ship) ->
    call(Ship, get_pos).

set_pos(Ship, X, Y) ->
    cast(Ship, {set_pos,X,Y}).

get_speed(Ship) ->
    call(Ship, get_speed).

set_speed(Ship, Dx, Dy) ->
    cast(Ship, {set_speed,Dx,Dy}).

zap(Ship) ->
    cast(Ship, zap).

get_state(Ship) ->
    call(Ship, get_state).

get_tc(Ship) ->
    call(Ship, get_tc).

set_ship(Ship, Name) ->				%Set a new ship chunk
    cast(Ship, {set_ship,Name}).

lua_do(Ship, Cmd) ->				%"do" any Lua command
    call(Ship, {lua_do,Cmd}).

gc(Ship) ->
    call(Ship, gc).

%% Internal protocol functions.

cast(Ship, Msg) ->
    Ship ! {cast,self(),Msg},
    ok.

call(Ship, Msg) ->
    Ship ! {call,self(),Msg},
    receive
	{reply,Ship,Rep} -> Rep
    end.

reply(To, Rep) ->
    To ! {reply,self(),Rep}.

%% Main loop.

init(X, Y, St0) ->
    universe:add_sector(X, Y, self()),		%Put us in the universe
    esdl_server:add_ship(),			%Add us to SDL
    {_,St1} = luerl:call_function([this_ship,start], [], St0),
    {_,St2} = luerl:call_function([this_ship,set_pos], [X,Y], St1),
    {_,St3} = luerl:call_function([this_ship,set_speed], [0,0], St2),
    proc_lib:init_ack({ok,self()}),
    loop(St3, infinity, make_ref(), 0).		%Start with dummy tick ref

%% loop(LuerlState, Tick, TickRef, TickCount) -> no_return().

loop(St0, Tick, Tref, Tc) ->
    receive
	tick ->
	    %% Clock tick, move the ship.
	    {_,St1} = luerl:call_function([this_ship,tick], [], St0),
	    NewTref = erlang:send_after(Tick, self(), tick),
	    loop(St1, Tick, NewTref, Tc+1);
	{cast,From,{set_tick,NewTick}} ->
	    erlang:cancel_timer(Tref),		%Cancel existing timer
	    {_,St1} = luerl:call_function([this_ship,set_tick], [NewTick], St0),
	    %% Set the new tick and get a new timer
	    NewTref = if NewTick =:= infinity ->
			      make_ref();	%Dummy tick ref
			 true ->
			      erlang:send_after(NewTick, self(), tick)
		      end,
	    loop(St1, NewTick, NewTref, Tc);
	{call,From,get_pos} ->
	    {[X,Y],St1} = luerl:call_function([this_ship,get_pos], [], St0),
	    reply(From, {X,Y}),
	    loop(St1, Tick, Tref, Tc);
	{cast,From,{set_pos,X,Y}} ->
	    {_,St1} = luerl:call_function([this_ship,set_pos],
					  [float(X),float(Y)], St0),
	    loop(St1, Tick, Tref, Tc);
	{call,From,get_speed} ->
	    {[Dx,Dy],St1} = luerl:call_function([this_ship,get_speed], [], St0),
	    reply(From, {Dx,Dy}),
	    loop(St1, Tick, Tref, Tc);
	{cast,From,{set_speed,Dx,Dy}} ->
	    {_,St1} = luerl:call_function([this_ship,set_speed],
					  [float(Dx),float(Dy)], St0),
	    loop(St1, Tick, Tref, Tc);
	{cast,From,zap} ->
	    {_,_} = luerl:call_function([this_ship,zap], [], St0),
	    timer:sleep(1500),
	    %% Remove ourselves from databases and die
	    esdl_server:del_ship(),
	    universe:del_ship(),
	    exit(zapped);
	{call,From,get_state} ->		%Get the luerl state
	    reply(From, {ok,St0}),
	    loop(St0, Tick, Tref, Tc);
	{call,From,get_tc} ->			%Get the tick count
	    reply(From, {ok,Tc}),
	    loop(St0, Tick, Tref, Tc);
	{cast,From,{set_ship,Name}} ->		%Set a new ship chunk
	    {_,St1} = do_set_ship(Name, Tick, St0),
	    loop(St1, Tick, Tref, Tc);
	{call,From,{lua_do,Cmd}} ->		%"do" any Lua command
	    {Rs,St1} = luerl:do(Cmd, St0),
	    reply(From, {ok,Rs}),
	    loop(St1, Tick, Tref, Tc);
	{call,From,gc} ->			%Gc the luerl state
	    St1 = luerl:gc(St0),
	    reply(From, ok),
	    loop(St1, Tick, Tref, Tc)
    end.

%% do_set_ship(ShipFileName, Tick, LuerlState) -> LuerlState.
%%  Load in a new ship chunk using require. This can make it more
%%  reload an updated ship. Get the existing position and speed and
%%  insert these into the new chunk.

do_set_ship(Name, Tick, St0) ->
    {[X,Y],St1} = luerl:call_function([this_ship,get_pos], [], St0),
    {[Dx,Dy],St2} = luerl:call_function([this_ship,get_speed], [], St1),
    {_,St3} = luerl:do("this_ship = require '" ++ Name ++ "'", St2),
    {_,St4} = luerl:call_function([this_ship,start], [], St3),
    {_,St5} = luerl:call_function([this_ship,set_pos], [X,Y], St4),
    {_,St6} = luerl:call_function([this_ship,set_speed], [Dx,Dy], St5),
    {Rs,St7} = luerl:call_function([this_ship,set_tick], [Tick], St6),
    {Rs,St7}.
