-module(zmq_socket).

-export([start/0,start_link/0]).
-export([init/0]).

-export([close/1,
         connect/1,
         disconnect/1,
         bind/1,
         unbind/1,
         send/1,
         send/2,
         recv/0,
         recv/1]).                     %Lua commands
 
%% Server state.
-record(state, {}).

%% Management API.

start() ->
    proc_lib:start(?MODULE, init, []).

start_link() ->
    proc_lib:start_link(?MODULE, init, []).

%% User API.

close(linger) ->
    cast(linger)

closed() ->
    cast()

connect(Address) ->
    cast(Address)

disconnect(Address) ->
    cast(Address)

bind(Address) ->
    cast(Address)

unbind(Address) ->
    cast(Address)

send(Message) ->
    cast(Message)

send(Message, Flags) ->
    cast(Message, Flags)

recv() ->
    cast()

recv(Flags) ->
    cast(Flags)

destroy(Linger) ->
    call({destroy_context,Linger}).

get(Option) ->
    call({get_context,Option}).

set(Option,Value) ->
    call({set_context_option,Option,Value}).

socket(SocketOptions) ->
    call({socket,SocketOptions}).

socket(SocketType, SocketOptions) ->
    call({socket,SocketType,SocketOptions}).

%% Internal protocol functions.

cast(Message) ->
    zmq ! {cast,self(),Message},
    ok.

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
    ets:insert(zmq, {version,0,1}),
    State = #state{},
    proc_lib:init_ack({ok,self()}),
    loop(State).

%% Main loop.

loop(State) ->
    receive
    {call,From,{add_context,Option,What}} ->
        Context = context(Option),
        reply(From, ets:insert(zmq, {Context,What})),
        loop(State)
    end.