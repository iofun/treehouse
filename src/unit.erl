-module(unit).

-export([start/3,start_link/3]).
-export([init/3]).
-export([set_tick/2,get_pos/1,set_pos/3,get_speed/1,set_speed/3,attack/1]).
-export([get_state/1,get_tc/1]).
-export([set_unit/2,lua_do/2,gc/1]).			%Lua commands

%% Management API.

start(X, Y, St) ->
    proc_lib:start(?MODULE, init, [X,Y,St]).

start_link(X, Y, St) ->
    proc_lib:start_link(?MODULE, init, [X,Y,St]).

%% User API.

set_tick(Unit, Tick) ->
    cast(Unit, {set_tick,Tick}).

get_pos(Unit) ->
    call(Unit, get_pos).

set_pos(Unit, X, Y) ->
    cast(Unit, {set_pos,X,Y}).

get_speed(Unit) ->
    call(Unit, get_speed).

set_speed(Unit, Dx, Dy) ->
    cast(Unit, {set_speed,Dx,Dy}).

attack(Unit) ->
    cast(Unit, attack).

get_state(Unit) ->
    call(Unit, get_state).

get_tc(Unit) ->
    call(Unit, get_tc).

set_unit(Unit, Name) ->				%Set a new unit chunk
    cast(Unit, {set_unit,Name}).

lua_do(Unit, Cmd) ->				%"do" any Lua command
    call(Unit, {lua_do,Cmd}).

gc(Unit) ->
    call(Unit, gc).

%% Internal protocol functions.

cast(Unit, Msg) ->
    Unit ! {cast,self(),Msg},
    ok.

call(Unit, Msg) ->
    Unit ! {call,self(),Msg},
    receive
	{reply,Unit,Rep} -> Rep
    end.

reply(To, Rep) ->
    To ! {reply,self(),Rep}.

%% Main loop.

init(X, Y, St0) ->
    map:add_sector(X, Y, self()),		%Put us in the map 
    esdl_server:add_unit(),			%Add us to SDL
    {_,St1} = luerl:call_function([this_unit,start], [], St0),
    {_,St2} = luerl:call_function([this_unit,set_pos], [X,Y], St1),
    {_,St3} = luerl:call_function([this_unit,set_speed], [0,0], St2),
    proc_lib:init_ack({ok,self()}),
    loop(St3, infinity, make_ref(), 0).		%Start with dummy tick ref

%% loop(LuerlState, Tick, TickRef, TickCount) -> no_return().

loop(St0, Tick, Tref, Tc) ->
    receive
	tick ->
	    %% Clock tick, move the unit.
	    {_,St1} = luerl:call_function([this_unit,tick], [], St0),
	    NewTref = erlang:send_after(Tick, self(), tick),
	    loop(St1, Tick, NewTref, Tc+1);
	{cast,From,{set_tick,NewTick}} ->
	    erlang:cancel_timer(Tref),		%Cancel existing timer
	    {_,St1} = luerl:call_function([this_unit,set_tick], [NewTick], St0),
	    %% Set the new tick and get a new timer
	    NewTref = if NewTick =:= infinity ->
			      make_ref();	%Dummy tick ref
			 true ->
			      erlang:send_after(NewTick, self(), tick)
		      end,
	    loop(St1, NewTick, NewTref, Tc);
	{call,From,get_pos} ->
	    {[X,Y],St1} = luerl:call_function([this_unit,get_pos], [], St0),
	    reply(From, {X,Y}),
	    loop(St1, Tick, Tref, Tc);
	{cast,From,{set_pos,X,Y}} ->
	    {_,St1} = luerl:call_function([this_unit,set_pos],
					  [float(X),float(Y)], St0),
	    loop(St1, Tick, Tref, Tc);
	{call,From,get_speed} ->
	    {[Dx,Dy],St1} = luerl:call_function([this_unit,get_speed], [], St0),
	    reply(From, {Dx,Dy}),
	    loop(St1, Tick, Tref, Tc);
	{cast,From,{set_speed,Dx,Dy}} ->
	    {_,St1} = luerl:call_function([this_unit,set_speed],
					  [float(Dx),float(Dy)], St0),
	    loop(St1, Tick, Tref, Tc);
	{cast,From,attack} ->
	    {_,_} = luerl:call_function([this_unit,attack], [], St0),
	    timer:sleep(1500),
	    %% Remove ourselves from databases and die
	    esdl_server:del_unit(),
	    map:del_unit(),
	    exit(killed);
	{call,From,get_state} ->		%Get the luerl state
	    reply(From, {ok,St0}),
	    loop(St0, Tick, Tref, Tc);
	{call,From,get_tc} ->			%Get the tick count
	    reply(From, {ok,Tc}),
	    loop(St0, Tick, Tref, Tc);
	{cast,From,{set_unit,Name}} ->		%Set a new unit chunk
	    {_,St1} = do_set_unit(Name, Tick, St0),
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

%% do_set_unit(UnitFileName, Tick, LuerlState) -> LuerlState.
%%  Load in a new unit chunk using require. This can make it more
%%  reload an updated unit. Get the existing position and speed and
%%  insert these into the new chunk.

do_set_unit(Name, Tick, St0) ->
    {[X,Y],St1} = luerl:call_function([this_unit,get_pos], [], St0),
    {[Dx,Dy],St2} = luerl:call_function([this_unit,get_speed], [], St1),
    {_,St3} = luerl:do("this_unit = require '" ++ Name ++ "'", St2),
    {_,St4} = luerl:call_function([this_unit,start], [], St3),
    {_,St5} = luerl:call_function([this_unit,set_pos], [X,Y], St4),
    {_,St6} = luerl:call_function([this_unit,set_speed], [Dx,Dy], St5),
    {Rs,St7} = luerl:call_function([this_unit,set_tick], [Tick], St6),
    {Rs,St7}.
