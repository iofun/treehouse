-module(unit).

-export([start/3,start_link/3]).
-export([init/3]).
-export([set_tick/2,get_position/1,set_position/3,get_speed/1,set_speed/3,zap/1]).
-export([get_state/1,get_tc/1]).
-export([set_unit/2,lua_do/2,gc/1]).            %Lua commands

%% Management API.

start(X, Y, State) ->
    proc_lib:start(?MODULE, init, [X,Y,State]).

start_link(X, Y, State) ->
    proc_lib:start_link(?MODULE, init, [X,Y,State]).

%% User API.

set_tick(Unit, Tick) ->
    cast(Unit, {set_tick,Tick}).

get_position(Unit) ->
    call(Unit, get_position).

set_position(Unit, X, Y) ->
    cast(Unit, {set_position,X,Y}).

get_speed(Unit) ->
    call(Unit, get_speed).

set_speed(Unit, Dx, Dy) ->
    cast(Unit, {set_speed,Dx,Dy}).

zap(Unit) ->
    cast(Unit, zap).

get_state(Unit) ->
    call(Unit, get_state).

get_tc(Unit) ->
    call(Unit, get_tc).

set_unit(Unit, Name) ->             %Set a new unit chunk
    cast(Unit, {set_unit,Name}).

lua_do(Unit, Command) ->                %"do" any Lua command
    call(Unit, {lua_do,Command}).

gc(Unit) ->
    call(Unit, gc).

%% Internal protocol functions.

cast(Unit, Message) ->
    Unit ! {cast,self(),Message},
    ok.

call(Unit, Message) ->
    Unit ! {call,self(),Message},
    receive
    {reply,Unit,Rep} -> Rep
    end.

reply(To, Rep) ->
    To ! {reply,self(),Rep}.

%% Main loop.

init(X, Y, State0) ->
    region:add_sector(X, Y, self()),        %Put us in the region
    {_,State1} = luerl:call_function([this_unit,start], [], State0),
    {_,State2} = luerl:call_function([this_unit,set_position], [X,Y], State1),
    {_,State3} = luerl:call_function([this_unit,set_speed], [0,0], State2),
    proc_lib:init_ack({ok,self()}),
    loop(State3, infinity, make_ref(), 0).      %Start with dummy tick ref

%% loop(LuerlState, Tick, TickRef, TickCount) -> no_return().

loop(State0, Tick, Tref, Tc) ->
    receive
    tick ->
        %% Clock tick, move the unit.
        {_,State1} = luerl:call_function([this_unit,tick], [], State0),
        NewTref = erlang:send_after(Tick, self(), tick),
        loop(State1, Tick, NewTref, Tc+1);
    {cast,From,{set_tick,NewTick}} ->
        erlang:cancel_timer(Tref),      %Cancel existing timer
        {_,State1} = luerl:call_function([this_unit,set_tick], [NewTick], State0),
        %% Set the new tick and get a new timer
        NewTref = if NewTick =:= infinity ->
                  make_ref();   %Dummy tick ref
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
    {call,From,get_state} ->        %Get the luerl state
        reply(From, {ok,State0}),
        loop(State0, Tick, Tref, Tc);
    {call,From,get_tc} ->           %Get the tick count
        reply(From, {ok,Tc}),
        loop(State0, Tick, Tref, Tc);
    {cast,From,{set_unit,Name}} ->      %Set a new unit chunk
        {_,State1} = do_set_unit(Name, Tick, State0),
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

%% do_set_unit(UnitFileName, Tick, LuerlState) -> LuerlState.
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