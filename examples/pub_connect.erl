#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -sname pub_connect -pa ../_rel/treehouse_release/lib/stdlib-3.0/ebin ../_rel/treehouse_release/lib/kernel-5.0/ebin ../_rel/treehouse_release/lib/chumak-1.1.1/ebin ../_rel/treehouse_release/lib/uuid-1.5.2-rc1/ebin ../_rel/treehouse_release/lib/luerl-0.3/ebin

main(_) ->
	io:format("Publisher connect treehouse OTP release erlang escript.\n",[]),

    Name = uuid:get_v4(),
    Aaa = uuid:uuid_to_string(Name),
    application:start(chumak),

    {ok, Socket} = chumak:socket(pub),

    case chumak:connect(Socket, tcp, "localhost", 8135) of
        {ok, _BindPid} ->
            io:format("Connection OK with Pid: ~p\n", [Socket]);
        {error, Reason} ->
            io:format("Connection Failed for this reason: ~p\n", [Reason]);
        X ->
            io:format("Unhandled reply for connect ~p \n", [X])
    end,
    loop(Socket, Aaa).

loop(Socket, Aaa) ->
    io:format("heartbeat ~p\n", [Aaa]),
    ok = chumak:send(Socket, <<"logging ", "Hello world">>),
    Bin = list_to_binary(Aaa),
    ok = chumak:send(Socket, Bin),
    timer:sleep(1000),
    loop(Socket, Aaa),
    erlang:halt(0).