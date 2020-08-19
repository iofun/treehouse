-module(luerl_unit).

%% The basic entry point to set up the function table.
-export([install/1]).

-import(luerl_lib, [lua_error/2,badarg_error/3]). %Shorten these

%% This works if luerl/ebin has been added to the path
-include_lib("luerl/src/luerl.hrl").

install(St) ->
    luerl_emul:alloc_table(table(), St).

%% table() -> [{FuncName,Function}].
%% Caller will convert this list to the correct format.

table() ->
    [{<<"self">>,#erl_func{code=fun self/2}},
     {<<"set_tick">>,#erl_func{code=fun set_tick/2}},
     {<<"get_pos">>,#erl_func{code=fun get_pos/2}},
     {<<"set_pos">>,#erl_func{code=fun set_pos/2}},
     {<<"get_speed">>,#erl_func{code=fun get_speed/2}},
     {<<"set_speed">>,#erl_func{code=fun set_speed/2}},
     {<<"attack">>,#erl_func{code=fun attack/2}},
     {<<"set_unit">>,#erl_func{code=fun set_unit/2}},
     {<<"do">>,#erl_func{code=fun do/2}},
     {<<"gc">>,#erl_func{code=fun gc/2}}
    ].

self([], St) ->
    {[#userdata{d=self()}],St}.

set_tick([#userdata{d=U},Tick], St) when is_number(Tick) ->
    unit:set_tick(U, trunc(Tick)),
    {[],St}.

get_pos([#userdata{d=U}], St) ->
    {X,Y} = unit:get_pos(U),
    {[X,Y],St};
get_pos(As, St) -> badarg_error(get_pos, As, St).

set_pos([#userdata{d=U},X,Y], St) when is_number(X), is_number(Y) ->
    unit:set_pos(U, X, Y),
    {[],St};
set_pos(As, St) -> badarg_error(set_pos, As, St).

get_speed([#userdata{d=U}], St) ->
    {X,Y} = unit:get_speed(U),
    {[X,Y],St};
get_speed(As, St) -> badarg_error(get_speed, As, St).

set_speed([#userdata{d=U},X,Y], St) when is_number(X), is_number(Y) ->
    unit:set_speed(U, X, Y),
    {[],St};
set_speed(As, St) -> badarg_error(set_speed, As, St).

attack([#userdata{d=U}], St) ->
    unit:attack(U),
    {[],St};
attack(As, St) -> badarg_error(attack, As, St).

set_unit([#userdata{d=U},Name], St) ->
    unit:set_unit(U, Name),
    {[],St};
set_unit(As, St) -> badarg_error(set_unit, As, St).

do([#userdata{d=U},Cmd], St) ->
    {ok,Rs} = unit:lua_do(U, binary_to_list(Cmd)),
    {Rs,St};
do(As, St) -> badarg_error(do, As, St).

gc([#userdata{d=U}], St) ->
    unit:gc(U),
    {[],St};
gc(As, St) -> badarg_error(gc, As, St).
