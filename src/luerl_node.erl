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
     {<<"attack">>,{function,fun attack/2}},
     {<<"hold">>,{function,fun hold/2}},
     {<<"move">>,{function,fun move/2}},
     {<<"rally">>,{function,fun rally/2}},
     {<<"patrol">>,{function,fun patrol/2}},
     {<<"gather">>,{function,fun gather/2}},
     {<<"return">>,{function,fun return/2}},
     {<<"spell">>,{function,fun spell/2}},
     {<<"build">>,{function,fun build/2}},
     {<<"cancel">>,{function,fun cancel/2}},
     {<<"repair">>,{function,fun repair/2}},
     {<<"stop">>,{function,fun stop/2}},
     {<<"set_unit">>,{function,fun set_unit/2}},
     {<<"do">>,{function,fun do/2}},  %% do what in the context of our implementation you guys? S=
     {<<"gc">>,{function,fun gc/2}}   %% please call the shit our of this!
    ].

self([], State) ->
    {[#userdata{d=self()}],State}.

set_tick([#userdata{d=U},Tick], State) when is_number(Tick) ->
    unit:set_tick(U, trunc(Tick)),
    {[],State}.

get_position([#userdata{d=U}], State) ->
    {X,Y} = unit:get_position(U),
    {[X,Y],State};
get_position(As, State) -> badarg_error(get_position, As, State).

set_position([#userdata{d=U},X,Y], State) when is_number(X), is_number(Y) ->
    unit:set_position(U, X, Y),
    {[],State};
set_position(As, State) -> badarg_error(set_position, As, State).

get_speed([#userdata{d=U}], State) ->
    {X,Y} = unit:get_speed(U),
    {[X,Y],State};
get_speed(As, State) -> badarg_error(get_speed, As, State).

set_speed([#userdata{d=U},X,Y], State) when is_number(X), is_number(Y) ->
    unit:set_speed(U, X, Y),
    {[],State};
set_speed(As, State) -> badarg_error(set_speed, As, State).

attack([#userdata{d=U}], State) ->
    unit:attack(U),
    {[],State};
attack(As, State) -> badarg_error(attack, As, State).

hold([#userdata{d=U}], State) ->
    unit:hold(U),
    {[],State};
hold(As, State) -> badarg_error(hold, As, State).

move([#userdata{d=U}], State) ->
    unit:move(U),
    {[],State};
move(As, State) -> badarg_error(move, As, State).

rally([#userdata{d=U}], State) ->
    unit:rally(U),
    {[],State};
rally(As, State) -> badarg_error(rally, As, State).

patrol([#userdata{d=U}], State) ->
    unit:patrol(U),
    {[],State};
patrol(As, State) -> badarg_error(patrol, As, State).

gather([#userdata{d=U}], State) ->
    unit:gather(U),
    {[],State};
gather(As, State) -> badarg_error(gather, As, State).

return([#userdata{d=U}], State) ->
    unit:return(U),
    {[],State};
return(As, State) -> badarg_error(return, As, State).

spell([#userdata{d=U}], State) ->
    unit:spell(U),
    {[],State};
spell(As, State) -> badarg_error(spell, As, State).

build([#userdata{d=U}], State) ->
    unit:build(U),
    {[],State};
build(As, State) -> badarg_error(build, As, State).

cancel([#userdata{d=U}], State) ->
    unit:cancel(U),
    {[],State};
cancel(As, State) -> badarg_error(cancel, As, State).

repair([#userdata{d=U}], State) ->
    unit:repair(U),
    {[],State};
repair(As, State) -> badarg_error(repair, As, State).

stop([#userdata{d=U}], State) ->
    unit:stop(U),
    {[],State};
stop(As, State) -> badarg_error(stop, As, State).

set_unit([#userdata{d=U},Name], State) ->
    unit:set_unit(U, Name),
    {[],State};
set_unit(As, State) -> badarg_error(set_unit, As, State).

do([#userdata{d=U},Command], State) ->
    {ok,Result} = unit:lua_do(U, binary_to_list(Command)),
    {Result,State};
do(As, State) -> badarg_error(do, As, State).

gc([#userdata{d=U}], State) ->
    unit:gc(U),
    {[],State};
gc(As, State) -> badarg_error(gc, As, State).
