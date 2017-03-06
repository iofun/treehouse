%% Some useful shell commands for testing.

-module(user_default).

-export([start/3,start_run/1,stop_run/0]).
-export([do_unit/2,do_unit/3,do_unit/4]).
-export([set_units/2,set_units/3,set_units/4]).
-export([test_cube/0]).

start(X, Y, S) ->
    tree_master:start(X, Y, S).

start_run(T) ->
    tree_master:start_run(T).

stop_run() ->
    tree_master:stop_run().

do_unit(I, Do) ->
    case tree_master:get_unit(whereis(tree_master), I) of
	{ok,Si} -> unit:Do(Si);
	error -> error
    end.

do_unit(I, Do, Arg) ->
    case tree_master:get_unit(whereis(tree_master), I) of
	{ok,Si} -> unit:Do(Si, Arg);
	error -> error
    end.

do_unit(I, Do, Arg1, Arg2) ->
    case tree_master:get_unit(whereis(tree_master), I) of
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

test_cube() ->
    %% test cube
    Cube = 480,
    tree_master:start(128,128,Cube*3),
    tree_master:start_run(80),
    set_units("attack",1,21),
    set_units("timid",22,79),
    set_units("paranoid",80,480),
    set_units("run",481,960),
    set_units("fly",961,1440).