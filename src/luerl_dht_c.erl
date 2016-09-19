-module(luerl_dht_c).

%% The basic entry point to set up the function table.
-export([install/1]).

-import(luerl_lib, [lua_error/2,badarg_error/3]). %Shorten these


install(State) ->
    luerl_emul:alloc_table(table(), State).

%% table() -> [{FuncName,Function}].
%% Caller will convert this list to the correct format.

table() ->
    [
     {<<"send_hash_message">>,{function,fun send_hash_message/2}}
    ].

send_hash_message([Message|_], State) ->
    hash_server:send_hash_message(Message),
    {[],State};
send_hash_message(As, State) -> badarg_error(send_hash_message, As, State).