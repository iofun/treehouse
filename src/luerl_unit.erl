-module(luerl_unit).

%% The basic entry point to set up the function table.
-export([install/1]).

-import(luerl_lib, [lua_error/2,badarg_error/3]).

%% This works if luerl/ebin has been added to the path
-include_lib("luerl/src/luerl.hrl").

%% Lua userdata, d=data, m=metadata
%% -record(userdata, {d,m=nil}).

install(State) ->
    luerl_emul:alloc_table(table(), State).

%% table() -> [{FuncName,Function}].
%% Caller will convert this install to the correct format.

table() ->
    [{<<"self">>,{function,fun self/2}},
     {<<"set_tick">>,{function,fun set_tick/2}},
     {<<"get_position">>,{function,fun get_position/2}},
     {<<"set_position">>,{function,fun set_position/2}},
     {<<"get_speed">>,{function,fun get_speed/2}},
     {<<"set_speed">>,{function,fun set_speed/2}},
     {<<"zap">>,{function,fun zap/2}},
     {<<"set_unit">>,{function,fun set_unit/2}},
     {<<"do">>,{function,fun do/2}},
     {<<"gc">>,{function,fun gc/2}}
    ].

self([], State) ->
    {[#userdata{d=self()}],State}.

set_tick([#userdata{d=S},Tick], State) when is_number(Tick) ->
    unit:set_tick(S, trunc(Tick)),
    {[],State}.

get_position([#userdata{d=S}], State) ->
    {X,Y} = unit:get_position(S),
    {[X,Y],State};
get_position(As, State) -> badarg_error(get_position, As, State).

set_position([#userdata{d=S},X,Y], State) when is_number(X), is_number(Y) ->
    unit:set_position(S, X, Y),
    {[],State};
set_position(As, State) -> badarg_error(set_position, As, State).

get_speed([#userdata{d=S}], State) ->
    {X,Y} = unit:get_speed(S),
    {[X,Y],State};
get_speed(As, State) -> badarg_error(get_speed, As, State).

set_speed([#userdata{d=S},X,Y], State) when is_number(X), is_number(Y) ->
    unit:set_speed(S, X, Y),
    {[],State};
set_speed(As, State) -> badarg_error(set_speed, As, State).

zap([#userdata{d=S}], State) ->
    unit:zap(S),
    {[],State};
zap(As, State) -> badarg_error(zap, As, State).

set_unit([#userdata{d=S},Name], State) ->
    unit:set_unit(S, Name),
    zmq:version(),
    {[],State};
set_unit(As, State) -> badarg_error(set_unit, As, State).

do([#userdata{d=S},Command], State) ->
    {ok,Rs} = unit:lua_do(S, binary_to_list(Command)),
    {Rs,State};
do(As, State) -> badarg_error(do, As, State).

gc([#userdata{d=S}], State) ->
    unit:gc(S),
    {[],State};
gc(As, State) -> badarg_error(gc, As, State).
