#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -sname sub_bind -pa ../_rel/treehouse_release/lib/stdlib-3.0/ebin ../_rel/treehouse_release/lib/kernel-5.0/ebin ../_rel/treehouse_release/lib/chumak-1.1.1/ebin ../_rel/treehouse_release/lib/uuid-1.5.2-rc1/ebin ../_rel/treehouse_release/lib/luerl-0.3/ebin

main(_) ->
	io:format("Subscriber bind treehouse OTP release erlang escript.\n",[]),
    application:ensure_all_started(chumak),
    {ok, Socket} = chumak:socket(sub),

    %% List of topics, put them on a list!
    Topic = <<" ">>,
    Heartbeat = <<"heartbeat">>,
    Asterisk = <<"asterisk">>,
    Currency = <<"currency">>,
    Beam = <<"beam">>,
    Logging = <<"logging">>,
    Upload = <<"upload">>,
    %% Erlang zmq subscribe socket and topics!
    chumak:subscribe(Socket, Topic),
    chumak:subscribe(Socket, Heartbeat),
    chumak:subscribe(Socket, Asterisk),
    chumak:subscribe(Socket, Currency),
    chumak:subscribe(Socket, Logging),
    chumak:subscribe(Socket, Upload),
    
    case chumak:bind(Socket, tcp, "localhost", 8135) of
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