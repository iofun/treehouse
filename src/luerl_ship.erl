-module(luerl_ship).

%% The basic entry point to set up the function table.
-export([install/1]).

-import(luerl_lib, [lua_error/2,badarg_error/3]). %Shorten these

%% This works if luerl/ebin has been added to the path
-include_lib("luerl/src/luerl.hrl").

%% -record(userdata, {d,m=nil}).

install(State) ->
    luerl_emul:alloc_table(table(), State).

%% table() -> [{FuncName,Function}].
%% Caller will convert this install to the correct format.

table() ->
    [{<<"self">>,{function,fun self/2}},
     {<<"set_tick">>,{function,fun set_tick/2}},
     {<<"get_pos">>,{function,fun get_pos/2}},
     {<<"set_pos">>,{function,fun set_pos/2}},
     {<<"get_speed">>,{function,fun get_speed/2}},
     {<<"set_speed">>,{function,fun set_speed/2}},
     {<<"zap">>,{function,fun zap/2}},
     {<<"set_ship">>,{function,fun set_ship/2}},
     {<<"do">>,{function,fun do/2}},
     {<<"gc">>,{function,fun gc/2}}
    ].

self([], State) ->
    {[#userdata{d=self()}],State}.

set_tick([#userdata{d=S},Tick], State) when is_number(Tick) ->
    ship:set_tick(S, trunc(Tick)),
    {[],State}.

get_pos([#userdata{d=S}], State) ->
    {X,Y} = ship:get_pos(S),
    {[X,Y],State};
get_pos(As, State) -> badarg_error(get_pos, As, State).

set_pos([#userdata{d=S},X,Y], State) when is_number(X), is_number(Y) ->
    ship:set_pos(S, X, Y),
    {[],State};
set_pos(As, State) -> badarg_error(set_pos, As, State).

get_speed([#userdata{d=S}], State) ->
    {X,Y} = ship:get_speed(S),
    {[X,Y],State};
get_speed(As, State) -> badarg_error(get_speed, As, State).

set_speed([#userdata{d=S},X,Y], State) when is_number(X), is_number(Y) ->
    ship:set_speed(S, X, Y),
    {[],State};
set_speed(As, State) -> badarg_error(set_speed, As, State).

zap([#userdata{d=S}], State) ->
    ship:zap(S),
    {[],State};
zap(As, State) -> badarg_error(zap, As, State).

set_ship([#userdata{d=S},Name], State) ->
    ship:set_ship(S, Name),
    {[],State};
set_ship(As, State) -> badarg_error(set_ship, As, State).

do([#userdata{d=S},Cmd], State) ->
    {ok,Rs} = ship:lua_do(S, binary_to_list(Cmd)),
    {Rs,State};
do(As, State) -> badarg_error(do, As, State).

gc([#userdata{d=S}], State) ->
    ship:gc(S),
    {[],State};
gc(As, State) -> badarg_error(gc, As, State).

    
