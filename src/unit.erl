-module(unit).

-export([start/3,start_link/3]).
-export([init/3]).
%% Lua commands
-export([set_tick/2,get_position/1,set_position/3,get_speed/1,set_speed/3,zap/1]).
-export([get_state/1,get_tc/1]).
-export([set_unit/2,lua_do/2,gc/1]).

%% Management API.

start(X, Y, State) ->
    proc_lib:start(?MODULE, init, [X,Y,State]).

start_link(X, Y, State) ->
    proc_lib:start_link(?MODULE, init, [X,Y,State]).

%% User API.

set_tick(unit, Tick) ->
    cast(unit, {set_tick,Tick}).

get_position(unit) ->
    call(unit, get_position).

set_position(unit, X, Y) ->
    cast(unit, {set_position,X,Y}).

get_speed(unit) ->
    call(unit, get_speed).

set_speed(unit, Dx, Dy) ->
    cast(unit, {set_speed,Dx,Dy}).

zap(unit) ->
    cast(unit, zap).

get_state(unit) ->
    call(unit, get_state).

get_tc(unit) ->
    call(unit, get_tc).

%Set a new unit chunk
set_unit(unit, Name) ->
    cast(unit, {set_unit,Name}).

%"do" any Lua command
lua_do(unit, Command) ->
    call(unit, {lua_do,Command}).

gc(unit) ->
    call(unit, gc).

%% Internal protocol functions.

cast(unit, Message) ->
    unit ! {cast,self(),Message},
    ok.

call(unit, Message) ->
    unit ! {call,self(),Message},
    receive
    {reply,unit,Rep} -> Rep
    end.

reply(To, Rep) ->
    To ! {reply,self(),Rep}.

%% Main loop.

init(X, Y, State0) ->
    %Put us in the region
    region:add_sector(X, Y, self()),
    {_,State1} = luerl:call_function([this_unit,start], [], State0),
    {_,State2} = luerl:call_function([this_unit,set_position], [X,Y], State1),
    {_,State3} = luerl:call_function([this_unit,set_speed], [0,0], State2),
    proc_lib:init_ack({ok,self()}),
    %Start with dummy tick ref
    loop(State3, infinity, make_ref(), 0).

%% loop(LuerlState, Tick, TickRef, TickCount) -> no_return().

loop(State0, Tick, Tref, Tc) ->
    receive
    tick ->
        %% Clock tick, move the unit.
        {_,State1} = luerl:call_function([this_unit,tick], [], State0),
        NewTref = erlang:send_after(Tick, self(), tick),
        loop(State1, Tick, NewTref, Tc+1);
    {cast,From,{set_tick,NewTick}} ->
        %Cancel existing timer
        erlang:cancel_timer(Tref),
        {_,State1} = luerl:call_function([this_unit,set_tick], [NewTick], State0),
        %% Set the new tick and get a new timer
        NewTref = if NewTick =:= infinity ->
                  %Dummy tick ref
                  make_ref();
             true ->
                  erlang:send_after(NewTick, self(), tick)
              end,
        loop(State1, NewTick, NewTref, Tc);
    {call,From,get_position} ->
        {[X,Y],State1} = luerl:call_function([this_unit,get_position], [], State0),
        reply(From, {X,Y}),
        loop(State1, Tick, Tref, Tc);
    {cast,From,{set_position,X,Y}} ->
        {_,State1} = luerl:call_function([this_unit,set_position],
                      [float(X),float(Y)], State0),
        loop(State1, Tick, Tref, Tc);
    {call,From,get_speed} ->
        {[Dx,Dy],State1} = luerl:call_function([this_unit,get_speed], [], State0),
        reply(From, {Dx,Dy}),
        loop(State1, Tick, Tref, Tc);
    {cast,From,{set_speed,Dx,Dy}} ->
        {_,State1} = luerl:call_function([this_unit,set_speed],
                      [float(Dx),float(Dy)], State0),
        loop(State1, Tick, Tref, Tc);
    {cast,From,zap} ->
        {_,_} = luerl:call_function([this_unit,zap], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(zapped);
    %Get the luerl state
    {call,From,get_state} ->
        reply(From, {ok,State0}),
        loop(State0, Tick, Tref, Tc);
    %Get the tick count
    {call,From,get_tc} ->
        reply(From, {ok,Tc}),
        loop(State0, Tick, Tref, Tc);
    %Set a new unit chunk
    {cast,From,{set_unit,Name}} ->
        {_,State1} = do_set_unit(Name, Tick, State0),
        loop(State1, Tick, Tref, Tc);
    %"do" any Lua command
    {call,From,{lua_do,Command}} ->
        {Rs,State1} = luerl:do(Command, State0),
        reply(From, {ok,Rs}),
        loop(State1, Tick, Tref, Tc);
    %Gc the luerl state
    {call,From,gc} ->
        State1 = luerl:gc(State0),
        reply(From, ok),
        loop(State1, Tick, Tref, Tc)
    end.

%% do_set_unit(unitFileName, Tick, LuerlState) -> LuerlState.
%%  Load in a new unit chunk using require. This can make it more
%%  reload an updated unit. Get the existing position and speed and
%%  insert these into the new chunk.

do_set_unit(Name, Tick, State0) ->
    {[X,Y],State1} = luerl:call_function([this_unit,get_position], [], State0),
    {[Dx,Dy],State2} = luerl:call_function([this_unit,get_speed], [], State1),
    {_,State3} = luerl:do("this_unit = require '" ++ Name ++ "'", State2),
    {_,State4} = luerl:call_function([this_unit,start], [], State3),
    {_,State5} = luerl:call_function([this_unit,set_position], [X,Y], State4),
    {_,State6} = luerl:call_function([this_unit,set_speed], [Dx,Dy], State5),
    {Rs,State7} = luerl:call_function([this_unit,set_tick], [Tick], State6),
    {Rs,State7}.