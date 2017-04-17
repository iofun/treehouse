-module(zmq_context).

-export([start/0,start_link/0]).
-export([init/0]).

-export([destroy/1,
         get/1,
         set/2,
         socket/2]).                           %Lua commands
 
%% Server state.
-record(state, {}).

%% Management API.

start() ->
    proc_lib:start(?MODULE, init, []).

start_link() ->
    proc_lib:start_link(?MODULE, init, []).

%% User API.

destroy(Linger) ->
    call({destroy,Linger}).

get(Option) ->
    call({get_context,Option}).

set(Option,Value) ->
    call({set_context_option,Option,Value}).

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
    register(zmq_context, self()),
    %% Create the zmq luerl driver interface.
    ets:new(zmq_context, [named_table,duplicate_bag,protected]),
    State = #state{},
    proc_lib:init_ack({ok,self()}),
    loop(State).

%% Main loop.

loop(State) ->
    receive
    {call,From,{get_context,X,Y}} ->
        Context = context(X, Y),
        reply(From, ets:lookup(zmq_context, Context)),
        loop(State);
    {call,From,{destroy,X,Y,What}} ->
        Context = context(X, Y),
        reply(From, ets:delete_object(zmq_context, {Context,What})),
        loop(State);
    {call,From,{socket,X,Y,What}} ->
        Context = context(X, Y),
        reply(From, ets:delete_object(zmq_context, {Context,What})),
        loop(State);
    {call,From,{add_context,Option,What}} ->
        Context = context(Option),
        reply(From, ets:insert(zmq_context, {Context,What})),
        loop(State)
    end.