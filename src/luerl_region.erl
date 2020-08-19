-module(luerl_universe).

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
    [{<<"size">>,#erl_func{code=fun size/2}},
     {<<"valid_x">>,#erl_func{code=fun valid_x/2}},
     {<<"valid_y">>,#erl_func{code=fun valid_y/2}},
     {<<"sector">>,#erl_func{code=fun sector/2}},
     {<<"get_sector">>,#erl_func{code=fun get_sector/2}},
     {<<"add_sector">>,#erl_func{code=fun add_sector/2}},
     {<<"rem_sector">>,#erl_func{code=fun rem_sector/2}},
     {<<"find_ship">>,#erl_func{code=fun find_ship/2}},
     {<<"del_ship">>,#erl_func{code=fun del_ship/2}}
    ].

size([], St) ->
    {X,Y} = universe:size(),
    {[float(X),float(Y)],St};
size(As, St) -> badarg_error(size, As, St).

valid_x([X], St) when is_number(X) ->
    {[universe:valid_x(X)],St};
valid_x(As, St) -> badarg_error(valid_x, As, St).

valid_y([Y], St) when is_number(Y) ->
    {[universe:valid_x(Y)],St};
valid_y(As, St) -> badarg_error(valid_y, As, St).

sector([X,Y], St) when is_number(X), is_number(Y) ->
    {Sx,Sy} = universe:sector(X, Y),
    {[float(Sx),float(Sy)],St};
sector(As, St) -> badarg_error(sector, As, St).

get_sector([X,Y], St) when is_number(X), is_number(Y) ->
    %% list_to_binary(pid_to_list(S))
    Ss = lists:map(fun({_,S}) -> #userdata{d=S} end,
		   universe:get_sector(X, Y)),
    {Ss,St};
get_sector(As, St) -> badarg_error(get_sector, As, St).

add_sector([X,Y], St) when is_number(X), is_number(Y) ->
    universe:add_sector(X, Y, self()),
    {[],St};
add_sector(As, St) -> badarg_error(add_sector, As, St).

rem_sector([X,Y], St) when is_number(X), is_number(Y) ->
    universe:rem_sector(X, Y, self()),
    {[],St};
rem_sector(As, St) -> badarg_error(rem_sector, As, St).

find_ship([#userdata{d=S}], St) ->
    Sec = universe:find_ship(S),
    {[Sec],St};
find_ship(As, St) -> badarg_error(find_ship, As, St).

del_ship([#userdata{d=S}], St) ->
    universe:del_ship(S),
    {[],St};
del_ship([], St) ->
    universe:del_ship(),
    {[],St};
del_ship(As, St) -> badarg_error(del_ship, As, St).
