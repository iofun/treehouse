-module(luerl_zmq_context).

%% The basic entry point to set up the function table.
-export([install/1]).

-import(luerl_lib, [lua_error/2,badarg_error/3]).

%% This works if luerl/ebin has been added to the path
-include_lib("luerl/src/luerl.hrl").

%% -record(userdata, {d,m=nil}).

install(State) ->
    luerl_emul:alloc_table(table(), State).

%% table() -> [{FuncName,Function}].
%% Caller will convert this install to the correct format.

table() ->
    [{<<"destroy">>,{function,fun destroy/2}},
     {<<"get_context">>,{function,fun get_context/2}},
     {<<"set_context">>,{function,fun set_context/2}},
     {<<"socket">>,{function,fun socket/3}}
    ].

destroy([X,Y], State) when is_number(X), is_number(Y) ->
    zmq_context:destroy(X, Y, self()),
    {[],State};
destroy(As, State) -> badarg_error(destroy, As, State).

get_context([X,Y], State) when is_number(X), is_number(Y) ->
    %% list_to_binary(pid_to_list(S))
    Ss = lists:map(fun({_,S}) -> #userdata{d=S} end,
           zmq_context:get_context(X, Y)),
    {Ss,State};
get_context(As, State) -> badarg_error(get_context, As, State).

set_context([X,Y], State) when is_number(X), is_number(Y) ->
    zmq_context:set_context(X, Y, self()),
    {[],State};
set_context(As, State) -> badarg_error(set_context, As, State).

socket(Context, Type, State) ->
    io:format("socket context ~p option\n", [Option]),
    {[],State};
socket(As, State) -> badarg_error(socket, As, State).