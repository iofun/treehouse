%% Some useful shell commands for testing.

-module(user_default).

-export([start/3,start_run/1,stop_run/0]).
-export([do_ship/2,do_ship/3,do_ship/4]).
-export([set_ships/2,set_ships/3,set_ships/4]).

start(X, Y, S) ->
    sim_master:start(X, Y, S).

start_run(T) ->
    sim_master:start_run(T).

stop_run() ->
    sim_master:stop_run().

do_ship(I, Do) ->
    case sim_master:get_ship(whereis(sim_master), I) of
    {ok,Si} -> ship:Do(Si);
    error -> error
    end.

do_ship(I, Do, Arg) ->
    case sim_master:get_ship(whereis(sim_master), I) of
    {ok,Si} -> ship:Do(Si, Arg);
    error -> error
    end.

do_ship(I, Do, Arg1, Arg2) ->
    case sim_master:get_ship(whereis(sim_master), I) of
    {ok,Si} -> ship:Do(Si, Arg1, Arg2);
    error -> error
    end.

set_ships(Ship, Sis) ->
    Set = fun (I) -> do_ship(I, set_ship, Ship) end,
    % Calls fun Set for each element in Sis List.
    lists:foreach(Set, Sis).

set_ships(Ship, From, To) ->
    set_ships(Ship, lists:seq(From, To)).

set_ships(Ship, From, To, Incr) ->
    set_ships(Ship, lists:seq(From, To, Incr)).
