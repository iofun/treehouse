-module(zmq_socket).

-export([start/0,start_link/0]).
-export([init/0]).

-export([close/1,
         connect/1,
         disconnect/1,
         bind/1,
         unbind/1,
         send/2,
         recv/1]).                     %Lua commands
 
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

cast(Message) ->
    zmq_socket ! {cast,self(),Message},
    ok.

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
    %% Create the zmq luerl driver interface.
    ets:new(zmq_socket, [named_table,duplicate_bag,protected]),
    State = #state{},
    proc_lib:init_ack({ok,self()}),
    loop(State).

%% Main loop.

loop(State) ->
    receive
    {call,From,{close,Linger,What}} ->

        %% Linger? What?

        %%Socket = socket(),
        %%reply(From, ets:delete_object(zmq_socket, {Socket,What})),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{connect,Address}} ->
    
        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{disconnect,Address}} ->
    
        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{bind,Address}} ->
    
        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{unbind,Address}} ->
    
        %%Context = context(),
        %%reply(From, ets:lookup(zmq_socket, Context)),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{send,Message,Flags,What}} ->
    
        %%Context = context(Option),
        %%reply(From, ets:insert(zmq_socket, {Context,What})),
        %%loop(State);
    
        reply(From, ok),
        loop(State);
    {call,From,{recv,Flags,What}} ->
    
        %%Context = context(Option),
        %%reply(From, ets:insert(zmq_socket, {Context,What})),
        %%loop(State)
    
        reply(From, ok),
        loop(State)
    end.