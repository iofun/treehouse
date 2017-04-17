-module(zmq).

-export([start/0,start_link/0]).
-export([init/0]).

-export([context/1,
         version/0]).                           %Lua commands
 
%% Server state.
-record(state, {}).

%% Management API.

start() ->
    proc_lib:start(?MODULE, init, []).

start_link() ->
    proc_lib:start_link(?MODULE, init, []).

%% User API.

context(Option) ->
    call({add_context,Option}).

version() ->
    [{version,X,Y,Z}] = ets:lookup(zmq, version),
    {X,Y}.

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
    ets:insert(zmq, {version,0,1,0}),
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