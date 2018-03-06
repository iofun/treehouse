-module(luerl_zmq).

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
    [{<<"socket">>,{function,fun socket/2}},
     {<<"bind">>,{function,fun bind/2}},
     {<<"unbind">>,{function,fun unbind/2}},
     {<<"send">>,{function,fun send/2}},
     {<<"recv">>,{function,fun recv/2}}
    ].

socket(Type, State) ->
    zmq:socket(Type),
    {[],State}.
%%socket(As, State) -> badarg_error(socket, As, State).

bind(Option, State) ->
    io:format("bind socket ~p option\n", [Option]),
    {[],State}.

unbind(Option, State) ->
    io:format("unbind socket ~p option\n", [Option]),
    {[],State}.

send(Option, State) ->
    io:format("send socket ~p option\n", [Option]),
    {[],State}.

recv(Option, State) ->
    io:format("recv socket ~p option\n", [Option]),
    {[],State}.
