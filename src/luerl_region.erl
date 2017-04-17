-module(luerl_region).

%% The basic entry point to set up the function table.
-export([install/1]).

-import(luerl_lib, [lua_error/2,badarg_error/3]).

%% This works if luerl/ebin has been added to the path
-include_lib("luerl/src/luerl.hrl").

%% -record(userdata, {d,m=nil}).

install(State) ->
    luerl_emul:alloc_table(table(), State).

%% table() -> [{FuncName,Function}].
%% Caller will convert this list to the correct format.

table() ->
    [{<<"size">>,{function,fun size/2}},
     {<<"valid_x">>,{function,fun valid_x/2}},
     {<<"valid_y">>,{function,fun valid_y/2}},
     {<<"sector">>,{function,fun sector/2}},
     {<<"get_sector">>,{function,fun get_sector/2}},
     {<<"add_sector">>,{function,fun add_sector/2}},
     {<<"rem_sector">>,{function,fun rem_sector/2}},
     {<<"find_unit">>,{function,fun find_unit/2}},
     {<<"del_unit">>,{function,fun del_unit/2}}
    ].

size([], State) ->
    {X,Y} = region:size(),
    {[float(X),float(Y)],State};
size(As, State) -> badarg_error(size, As, State).

valid_x([X], State) when is_number(X) ->
    {[region:valid_x(X)],State};
valid_x(As, State) -> badarg_error(valid_x, As, State).

valid_y([Y], State) when is_number(Y) ->
    {[region:valid_x(Y)],State};
valid_y(As, State) -> badarg_error(valid_y, As, State).

sector([X,Y], State) when is_number(X), is_number(Y) ->
    {Sx,Sy} = region:sector(X, Y),
    {[float(Sx),float(Sy)],State};
sector(As, State) -> badarg_error(sector, As, State).

get_sector([X,Y], State) when is_number(X), is_number(Y) ->
    %% list_to_binary(pid_to_list(S))
    Ss = lists:map(fun({_,S}) -> #userdata{d=S} end,
           region:get_sector(X, Y)),
    {Ss,State};
get_sector(As, State) -> badarg_error(get_sector, As, State).

add_sector([X,Y], State) when is_number(X), is_number(Y) ->
    region:add_sector(X, Y, self()),
    {[],State};
add_sector(As, State) -> badarg_error(add_sector, As, State).

rem_sector([X,Y], State) when is_number(X), is_number(Y) ->
    region:rem_sector(X, Y, self()),
    {[],State};
rem_sector(As, State) -> badarg_error(rem_sector, As, State).

find_unit([#userdata{d=S}], State) ->
    Sec = region:find_unit(S),
    {[Sec],State};
find_unit(As, State) -> badarg_error(find_unit, As, State).

del_unit([#userdata{d=S}], State) ->
    region:del_unit(S),
    {[],State};
del_unit([], State) ->
    region:del_unit(),
    {[],State};
del_unit(As, State) -> badarg_error(del_unit, As, State).