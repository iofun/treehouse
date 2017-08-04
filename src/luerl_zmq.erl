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
     {<<"connect">>,{function,fun connect/2}},
     {<<"disconnect">>,{function,fun disconnect/2}},
     {<<"bind">>,{function,fun bind/2}},
     {<<"unbind">>,{function,fun unbind/2}},
     {<<"send">>,{function,fun send/2}},
     {<<"recv">>,{function,fun recv/2}}
    ].

socket(Type, State) ->
    SocketOption = "lol",
    zmq:socket(Type, SocketOption),
    io:format("socket ~p type option ~p\n", [Type, SocketOption]),
    lager:warning("Yo this socket type ~p option here ~p \n", [Type, SocketOption]),
    {[],State};
socket(As, State) -> badarg_error(socket, As, State).

connect(Option, State) ->
    io:format("connect socket ~p option\n", [Option]),
    {[],State}.

disconnect(Option, State) ->
    io:format("disconnect socket ~p option\n", [Option]),
    {[],State}.

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
