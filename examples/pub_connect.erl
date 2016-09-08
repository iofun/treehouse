#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -sname pub_connect -pa ../_rel/treehouse_release/lib/stdlib-3.0/ebin ../_rel/treehouse_release/lib/kernel-5.0/ebin ../_rel/treehouse_release/lib/chumak-1.1.1/ebin ../_rel/treehouse_release/lib/uuid-1.5.2-rc1/ebin ../_rel/treehouse_release/lib/jsx-2.8.0/ebin ../_rel/treehouse_release/lib/luerl-0.3/ebin

main(_) ->
	io:format("Publisher connect treehouse OTP release erlang escript.\n",[]),
    application:start(chumak),
    Uuid = uuid:get_v4(),
    UuidString = uuid:uuid_to_string(Uuid),
    {ok, Socket} = chumak:socket(pub),

    case chumak:connect(Socket, tcp, "localhost", 8135) of
        {ok, _BindPid} ->
            io:format("Connection OK with Pid: ~p\n", [Socket]);
        {error, Reason} ->
            io:format("Connection Failed for this reason: ~p\n", [Reason]);
        X ->
            io:format("Unhandled reply for connect ~p \n", [X])
    end,
    loop(Socket, UuidString).

loop(Socket, UuidString) ->
    Timestamp0 = erlang:timestamp(),
    Timestamp1 = [element(1,Timestamp0), element(2,Timestamp0)],
    Timestamp2 = [integer_to_binary(X) || X <- Timestamp1, integer(X)],
    Timestamp = list_to_binary(Timestamp2),

    Json = jsx:encode([{<<"timestamp">>, list_to_integer(binary_to_list(Timestamp))},
        {<<"uuid">>, iolist_to_binary(UuidString)}]),
    Message = list_to_binary(["heartbeat ", Json]),

    ok = chumak:send(Socket, Message),
    timer:sleep(500),
    loop(Socket, UuidString),
    erlang:halt(0).