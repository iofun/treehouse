-module(zmq_socket).

-export([start/0,start_link/0]).
-export([init/0]).

%% define and export the implementation interface API with the goal of consistently
%% match https://moteus.github.io/lzmq/modules/lzmq.html lzmq API when it is possible.

-export([close/1,       %Lua commands
         connect/1,
         disconnect/1,
         bind/1,
         unbind/1,
         send/2,
         recv/1]).

%% Server state.
-record(state, {}).

%% Management API.

start() ->
    proc_lib:start(?MODULE, init, []).

start_link() ->
    proc_lib:start_link(?MODULE, init, []).

%% User API.

close(Linger) ->
    call({close,Linger}).

connect(Address) ->
    call({connect,Address}).

disconnect(Address) ->
    call({disconnect,Address}).

bind(Address) ->
    call({bind,Address}).

unbind(Address) ->
    call({unbind,Address}).

send(Message,Flags) ->
    call({send,Message,Flags}).

recv(Flags) ->
    call({recv,Flags}).

%% Internal protocol functions.

%%cast(Message) ->
%%    zmq_socket ! {cast,self(),Message},
%%    ok.

call(Message) ->
    U = whereis(zmq_socket),
    U ! {call,self(),Message},
    receive
    {reply,U,Rep} -> Rep
    end.

reply(To, Rep) ->
    To ! {reply,self(),Rep}.

%% Initialise it all.

init() ->
    register(zmq_socket, self()),
    
    %% Create the ZeroMQ luerl driver interface ETS table ?.   <--------------- !!!

    ets:new(zmq_socket, [named_table,duplicate_bag,protected]),

    %% BUT ..

    %% WHY THE FUCK?    

    State = #state{},
    proc_lib:init_ack({ok,self()}),
    loop(State).

%% Main loop.

loop(State) ->
    receive
    {call,From,{close,Linger,What}} ->

        %% close Linger? What?

        lager:warning("close Linger ~p, What? ~p \n", [Linger, What]),

        %%Socket = socket(),
        %%reply(From, ets:delete_object(zmq_socket, {Socket,What})),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{connect,Address}} ->
    
        %% connect Address?

        lager:warning("connect Address? ~p \n", [Address]),

        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{disconnect,Address}} ->

        %% disconnect Address?

        lager:warning("disconnect Address? ~p \n", [Address]),
    
        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{bind,Address}} ->

        %% bind Address?

        lager:warning("bind Address? ~p \n", [Address]),
    
        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{unbind,Address}} ->

        %% unbind Address?

        lager:warning("unbind Address? ~p \n", [Address]),
    
        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{send,Message,Flags,What}} ->

        %% send Message, Flags, What?

        lager:warning("send Message ~p, Flags ~p, What? ~p \n", [Message, Flags, What]),
    
        %%Context = context(Option),
        %%reply(From, ets:insert(zmq_socket, {Context,What})),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{recv,Flags,What}} ->

        %% recv Flags, What?

        lager:warning("recv Flags ~p, What? ~p \n", [Flags, What]),
    
        %%Context = context(Option),
        %%reply(From, ets:insert(zmq_socket, {Context,What})),
        %%loop(State)
    
        reply(From, ok),
        loop(State)
    end.