-module(sub_bind).

-export([start_link/0,start/0,stop/0]).
-export([init/0]).
-export([send_message/1]).

%% Management API.

start() ->
    proc_lib:start(?MODULE, init, []).

start_link() ->
    proc_lib:start_link(?MODULE, init, []).

stop() ->
    cast(stop).

%% Server state.

-record(state, {}).

%% User API.

send_message(Message) ->
    cast({send_message,Message}).

%% Internal protocol functions.

cast(Message) ->
    sub_server ! {cast,self(),Message},
    ok.

%% Initialise it all.

init() ->
    application:ensure_all_started(chumak),
    %%Val = "Carepetch",
    %%ID = crypto:hash(sha, Val),
    %%io:format("~p ~p ~n", [Val, ID]),
    {ok, Socket} = chumak:socket(sub),
    %% List of topics, put them in a list or something.
    Topic = <<" ">>,
    Heartbeat = <<"heartbeat">>,
    Asterisk = <<"asterisk">>,
    Currency = <<"currency">>,
    Logging = <<"logging">>,
    Upload = <<"upload">>,
    %% Erlang zmq subscribe socket and topics!
    chumak:subscribe(Socket, Topic),
    chumak:subscribe(Socket, Heartbeat),
    chumak:subscribe(Socket, Asterisk),
    chumak:subscribe(Socket, Currency),
    chumak:subscribe(Socket, Logging),
    chumak:subscribe(Socket, Upload),
    %% Hello bind this case
    case chumak:bind(Socket, tcp, "localhost", 8135) of
        {ok, _BindPid} ->
            io:format("Binding OK with Pid: ~p\n", [Socket]);
        {error, Reason} ->
            io:format("Connection Failed for this reason: ~p\n", [Reason]);
        X ->
            io:format("Unhandled reply for bind ~p \n", [X])
    end,
    %% spawn external process that handle the zmq loop
    spawn_link(fun () ->
            zmq_loop(Socket)
    end),
    register(sub_server, self()),
    proc_lib:init_ack({ok,self()}),
    loop(#state{}).

zmq_loop(Socket) ->
    {ok, Data1} = chumak:recv(Socket),
    io:format("Received ~p\n", [Data1]),
    zmq_loop(Socket).

loop(State) ->
    receive
        {cast,From,{send_message,Message}} ->
            io:format("~w: ~p\n", [From,Message]),
            loop(State);
        {cast,_From,stop} ->            %We're done
            ok;
        _ ->                            %Ignore everything else
            loop(State)
    end.