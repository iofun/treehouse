-module(zmq_context).

-export([start/0,start_link/0]).
-export([init/0]).

%% define and export the implementation interface API with the goal of consistently
%% match https://moteus.github.io/lzmq/modules/lzmq.html lzmq API when it is possible.

-export([destroy/1,     %Lua commands
         socket/2]).
 
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

socket(SocketType, SocketOptions) ->
    call({socket,SocketType,SocketOptions}).

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
    register(zmq:context, self()),

    %% Create the ZeroMQ luerl driver interface ETS table ?.   <--------------- !!!

    ets:new(zmq_context, [named_table,duplicate_bag,protected]),

    %% BUT ..

    %% WHY THE FUCK?
    
    State = #state{},
    proc_lib:init_ack({ok,self()}),
    loop(State).

%% Main loop.

loop(State) ->
    receive
    {call,From,{destroy,Linger,What}} ->

        %% close Linger? What?

        lager:warning("destroy Linger ~p, What? ~p \n", [Linger, What]),

        %%Context = context(X, Y),
        %%reply(From, ets:delete_object(zmq_context, {Context,What})),

        reply(From, ok),
        loop(State);
    {call,From,{socket,SocketType,SocketOptions,What}} ->

        %% socket SocketType, SocketOptions, What?

        lager:warning("socket SocketType ~p, SocketOptions ~p, What? ~p \n", [SocketType, SocketOptions, What]),

        %%Context = context(X, Y),
        %%reply(From, ets:delete_object(zmq_context, {Context,What})),
        reply(From, ok),
        loop(State)