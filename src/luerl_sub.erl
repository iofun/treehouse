-module(luerl_sub).

%% The basic entry point to set up the function table.
-export([install/1]).

-import(luerl_lib, [lua_error/2,badarg_error/3]). %Shorten these


install(State) ->
    luerl_emul:alloc_table(table(), State).

%% table() -> [{FuncName,Function}].
%% Caller will convert this list to the correct format.

table() ->
    [
     {<<"send_message">>,{function,fun send_message/2}}
    ].

send_message([Message|_], State) ->
    sub_server:send_message(Message),
    {[],State};
send_message(As, State) -> badarg_error(send_message, As, State).