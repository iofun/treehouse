#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -sname sub_bind -pa ../_rel/treehouse_release/lib/stdlib-3.0/ebin ../_rel/treehouse_release/lib/kernel-5.0/ebin ../_rel/treehouse_release/lib/chumak-1.1.1/ebin ../_rel/treehouse_release/lib/uuid-1.5.2-rc1/ebin ../_rel/treehouse_release/lib/luerl-0.3/ebin

main(_) ->
	io:format("Subscriber bind treehouse OTP release erlang escript.\n",[]),
    application:ensure_all_started(chumak),
    {ok, Socket} = chumak:socket(sub),
    %% Subscribe topic
    Heartbeat = <<"heartbeat">>,
    chumak:subscribe(Socket, Heartbeat),
    case chumak:bind(Socket, tcp, "localhost", 5813) of
        {ok, _BindPid} ->
            io:format("Binding OK with Pid: ~p\n", [Socket]);
        {error, Reason} ->
            io:format("Connection Failed for this reason: ~p\n", [Reason]);
        X ->
            io:format("Unhandled reply for bind ~p \n", [X])
    end,
    loop(Socket).

loop(Socket) ->
    {ok, Data1} = chumak:recv(Socket),
    io:format("Received ~p\n", [Data1]),
    loop(Socket),
    erlang:halt(0).