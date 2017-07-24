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
    [
     {<<"context">>,{function,fun context/2}}
    ].

context(Option, State) ->
    io:format("invoker content ~p option\n", [Option]),
    {[],State};
context(As, State) -> badarg_error(context, As, State).