-module(zmq).

%% define and export the implementation interface API with the goal of consistently
%% match https://moteus.github.io/lzmq/modules/lzmq.html lzmq API when it is possible.

-export([start/0,start_link/0]).
-export([init/0]).

-export([socket/2,      %Lua commands      
         connect/1,
         disconnect/1,
         bind/1,
         unbind/1,
         send/2,
         recv/1,
         version/0]).
 
%% Server state.
-record(state, {}).

%% Management API.

start() ->
    proc_lib:start(?MODULE, init, []).

start_link() ->
    proc_lib:start_link(?MODULE, init, []).

%% User API.

socket(SocketType, SocketOptions) ->
    call({socket,SocketType,SocketOptions}).

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

version() ->
    [{version,X,Y,Z}] = ets:lookup(zmq, version),
    {X,Y,Z}.

%% Internal protocol functions.

%%cast(Message) ->
%%    zmq ! {cast,self(),Message},
%%    ok.

call(Message) ->
    U = whereis(zmq),
    U ! {call,self(),Message},
    receive
    {reply,U,Rep} -> Rep
    end.

reply(To, Rep) ->
    To ! {reply,self(),Rep}.

%% Initialise it all.

init() ->
    register(zmq, self()),
    %% Create the zmq luerl driver interface.
    ets:new(zmq, [named_table,duplicate_bag,protected]),
    ets:insert(zmq, {version,0,1,0}),
    State = #state{},
    proc_lib:init_ack({ok,self()}),
    loop(State).

%% Main loop.

loop(State) ->
    receive
    {call,From,{connect,Address}} ->
    
        %% connect Address?

        lager:warning("connect Address? ~p \n", [Address]),

        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
    
        reply(From, ok),
        loop(State);
    {call,From,{disconnect,Address}} ->

        %% disconnect Address?

        lager:warning("disconnect Address? ~p \n", [Address]),
    
        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
    
        reply(From, ok),
        loop(State);
    {call,From,{bind,Address}} ->

        %% bind Address?

        lager:warning("bind Address? ~p \n", [Address]),
    
        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
    
        reply(From, ok),
        loop(State);
    {call,From,{unbind,Address}} ->

        %% unbind Address?

        lager:warning("unbind Address? ~p \n", [Address]),
    
        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
    
        reply(From, ok),
        loop(State);
    {call,From,{send,Message,Flags,What}} ->

        %% send Message, Flags, What?

        lager:warning("send Message ~p, Flags ~p, What? ~p \n", [Message, Flags, What]),
    
        %%Context = context(Option),
        %%reply(From, ets:insert(zmq_socket, {Context,What})),
    
        reply(From, ok),
        loop(State);
    {call,From,{recv,Flags,What}} ->

        %% recv Flags, What?

        lager:warning("recv Flags ~p, What? ~p \n", [Flags, What]),
    
        %%Context = context(Option),
        %%reply(From, ets:insert(zmq_socket, {Context,What})),
    
        reply(From, ok),
        loop(State);
    {call,From,{socket,SocketType,SocketOptions,What}} ->

        %% socket SocketType, SocketOptions, What?

        lager:warning("socket SocketType ~p, SocketOptions ~p, What? ~p \n", [SocketType, SocketOptions, What]),

        %%Context = context(X, Y),
        %%reply(From, ets:delete_object(zmq_context, {Context,What})),
        reply(From, ok),
        loop(State)
    end.