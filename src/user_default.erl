%% Some useful shell commands for the universe simulator.

-module(user_default).

-export([start/3,start_run/1,stop_run/0]).
-export([p/1,pp/1]).
-export([do_unit/2,do_unit/3,do_unit/4]).
-export([set_units/2,set_units/3,set_units/4]).

start(X, Y, U) ->
    sim_master:start(X, Y, U).

start_run(T) ->
    sim_master:start_run(T).

stop_run() ->
    sim_master:stop_run().

p(T) ->
    io:format("~w\n", [T]).

pp(T) ->
    io:format("~p\n", [T]).

%% do_unit(Index, Command)
%% do_unit(Index, Command, Arg)
%% do_unit(Index, Command, Arg1, Arg2)

do_unit(I, Do) ->
    case sim_master:get_unit(whereis(sim_master), I) of
	{ok,Ui} -> unit:Do(Ui);
	error -> error
    end.

do_unit(I, Do, Arg) ->
    case sim_master:get_unit(whereis(sim_master), I) of
	{ok,Ui} -> unit:Do(Ui, Arg);
	error -> error
    end.

do_unit(I, Do, Arg1, Arg2) ->
    case sim_master:get_unit(whereis(sim_master), I) of
	{ok,Ui} -> unit:Do(Ui, Arg1, Arg2);
	error -> error
    end.

%% set_units(NewUnit, [Index]).
%% set_units(NewUnit, First, Last).
%% set_units(NewUnit, First, Last, Increment).

set_units(Unit, Uis) ->
    Set = fun (I) -> do_unit(I, set_unit, Unit) end,
    lists:foreach(Set, Uis).

set_units(Unit, From, To) ->
    set_units(Unit, lists:seq(From, To)).

set_units(Unit, From, To, Incr) ->
    set_units(Unit, lists:seq(From, To, Incr)).
