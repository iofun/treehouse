-module(luerl_zmq_context).

%% The basic entry point to set up the function table.
-export([install/1]).

-import(luerl_lib, [lua_error/2,badarg_error/3]).

%% This works if luerl/ebin has been added to the path
-include_lib("luerl/src/luerl.hrl").

%% 
%% -record(userdata, {d,m=nil}).

install(State) ->
    luerl_emul:alloc_table(table(), State).

%% table() -> [{FuncName,Function}].
%% Caller will convert this install to the correct format.

table() ->
    [{<<"destroy">>,{function,fun destroy/2}},
     {<<"socket">>,{function,fun socket/2}}
    ].

destroy(Linger, State) ->

    %%zmq_context:destroy(Linger, self()),
    %%{[],State};

destroy(As, State) -> badarg_error(destroy, As, State).


socket([Context, Type], State) ->
    io:format("socket context ~p type\n", [Context, Type]),
    {[],State};
socket(As, State) -> badarg_error(socket, As, State).