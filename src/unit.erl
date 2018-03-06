-module(unit).

%% It really seem that our own OTP behavior it's painfully needed.
%% and with it hopefully grasp the power and need of define  your own behaviours.

-export([start/3,start_link/3]).
-export([init/3]).

-export([set_tick/2,
         get_position/1,
         set_position/3,
         get_speed/1,
         set_speed/3,
         %% and now for something completly different!
         move/1,
         rally/1,
         patrol/1,
         gather/1,
         return/1,
         spell/1,    % how about burrow/unborrow?
         build/1,
         cancel/1,
         repair/1,
         stop/1,
         hold/1,
         attack/1]).

-export([get_state/1,get_tc/1]).
-export([set_unit/2,lua_do/2,gc/1]).    %  LuaLang commands

%% Management API.

start(X, Y, State) ->
    proc_lib:start(?MODULE, init, [X,Y,State]).

start_link(X, Y, State) ->
    proc_lib:start_link(?MODULE, init, [X,Y,State]).

%% Human Unit API.

move(Unit) ->
    cast(Unit, move).

rally(Unit) ->
    cast(Unit, rally).

patrol(Unit) ->
    cast(Unit, patrol).

gather(Unit) ->
    cast(Unit, gather).

return(Unit) ->
    cast(Unit, return).

spell(Unit) ->
    cast(Unit, spell).

build(Unit) ->
    cast(Unit, build).

cancel(Unit) ->
    cast(Unit, cancel).

repair(Unit) ->
    cast(Unit, repair).

stop(Unit) ->
    cast(Unit, stop).

hold(Unit) ->
    cast(Unit, hold).

attack(Unit) ->
    cast(Unit, attack).

%% Seriously low level no-horn functions

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

get_state(Unit) ->
    call(Unit, get_state).

get_tc(Unit) ->
    call(Unit, get_tc).

set_unit(Unit, Name) ->              % Set a new unit chunk
    cast(Unit, {set_unit,Name}).

lua_do(Unit, Command) ->             % "do" any Lua command
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
    region:add_sector(X, Y, self()),       % Put us in some region
    {_,State1} = luerl:call_function([this_unit,start], [], State0),
    {_,State2} = luerl:call_function([this_unit,set_position], [X,Y], State1),
    {_,State3} = luerl:call_function([this_unit,set_speed], [0,0], State2),
    proc_lib:init_ack({ok,self()}),
    loop(State3, infinity, make_ref(), 0). % Start with dummy tick ref

%% loop(LuerlState, Tick, TickRef, TickCount) -> no_return().

loop(State0, Tick, Tref, Tc) ->
    receive
    tick ->
        %% Clock tick, move the unit.
        {_,State1} = luerl:call_function([this_unit,tick], [], State0),
        NewTref = erlang:send_after(Tick, self(), tick),
        loop(State1, Tick, NewTref, Tc+1);
    {cast,From,{set_tick,NewTick}} ->
        %%  logging unused variable!
        lager:warning("set_tick From? ~p \n", [From]),
        erlang:cancel_timer(Tref),    % Cancel existing timer
        {_,State1} = luerl:call_function([this_unit,set_tick], [NewTick], State0),
        %% Set the new tick and get a new timer
        NewTref = if NewTick =:= infinity ->
                  make_ref();    % Dummy tick ref
             true ->
                  erlang:send_after(NewTick, self(), tick)
              end,
        loop(State1, NewTick, NewTref, Tc);
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
    {cast,From,attack} ->
        %%  logging unused variable!
        lager:warning("unit attack from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,attack], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(zapped);
    {cast,From,return} ->
        %%  logging unused variable!
        lager:warning("unit return from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,return], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(returned);
%% repair, stop, hold, attack
    {cast,From,move} ->
        %%  logging unused variable!
        lager:warning("unit move from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,move], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(moved);
    {cast,From,rally} ->
        %%  logging unused variable!
        lager:warning("unit rally from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,rally], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(pointed);
    {cast,From,patrol} ->
        %%  logging unused variable!
        lager:warning("unit patrol from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,patrol], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(patroled);
    {cast,From,gather} ->
        %%  logging unused variable!
        lager:warning("unit gather from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,gather], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(gathered);
    {cast,From,spell} ->
        %%  logging unused variable!
        lager:warning("unit spell from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,spell], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(spelled);
    {cast,From,build} ->
        %%  logging unused variable!
        lager:warning("unit build from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,build], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(morphed);
    {cast,From,repair} ->
        %%  logging unused variable!
        lager:warning("unit repair from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,repair], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(repaired);
    {cast,From,cancel} ->
        %%  logging unused variable!
        lager:warning("unit cancel from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,cancel], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(canceled);
    {cast,From,stop} ->
        %%  logging unused variable!
        lager:warning("unit stop from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,stop], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(stoped);
    {cast,From,hold} ->
        %%  logging unused variable!
        lager:warning("unit hold from? ~p \n", [From]),
        {_,_} = luerl:call_function([this_unit,hold], [], State0),
        timer:sleep(1500),
        %% Remove ourselves from databases and die
        region:del_unit(),
        exit(holded);
    {call,From,get_state} ->        %Get the luerl state
        reply(From, {ok,State0}),
        loop(State0, Tick, Tref, Tc);
    {call,From,get_tc} ->           %Get the tick count
        reply(From, {ok,Tc}),
        loop(State0, Tick, Tref, Tc);
    {cast,From,{set_unit,Name}} ->      %Set a new unit chunk
        %%  logging unused variable!
        lager:warning("set_unit From? ~p \n", [From]),
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
