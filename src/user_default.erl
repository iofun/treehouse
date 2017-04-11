%% Some useful shell commands for testing.

-module(user_default).

-export([start/3,start_run/1,stop_run/0]).
-export([do_unit/2,do_unit/3,do_unit/4]).
-export([set_units/2,set_units/3,set_units/4]).

start(X, Y, S) ->
    sim_master:start(X, Y, S).

start_run(T) ->
    sim_master:start_run(T).

stop_run() ->
    sim_master:stop_run().

do_unit(I, Do) ->
    case sim_master:get_unit(whereis(sim_master), I) of
    {ok,Si} -> unit:Do(Si);
    error -> error
    end.

do_unit(I, Do, Arg) ->
    case sim_master:get_unit(whereis(sim_master), I) of
    {ok,Si} -> unit:Do(Si, Arg);
    error -> error
    end.

do_unit(I, Do, Arg1, Arg2) ->
    case sim_master:get_unit(whereis(sim_master), I) of
    {ok,Si} -> unit:Do(Si, Arg1, Arg2);
    error -> error
    end.

set_units(Unit, Sis) ->
    Set = fun (I) -> do_unit(I, set_unit, Unit) end,
    % Calls fun Set for each element in Sis List.
    lists:foreach(Set, Sis).

set_units(Unit, From, To) ->
    set_units(Unit, lists:seq(From, To)).

set_units(Unit, From, To, Incr) ->
    set_units(Unit, lists:seq(From, To, Incr)).