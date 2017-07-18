-module(region).

-export([start/2,start_link/2]).
-export([init/2]).
-export([sector/2,get_sector/2,add_sector/3,rem_sector/3]).
-export([size/0,valid_x/1,valid_y/1]).
-export([find_unit/1,del_unit/0,del_unit/1]).

%% testing init work if works move this away

-export([test_me/0,test_me/1]).

%% kthxbye

%% Server state.
-record(state, {xsize,ysize}).

%% Management API.

start(Xsize, Ysize) ->
    proc_lib:start(?MODULE, init, [Xsize,Ysize]).

start_link(Xsize, Ysize) ->
    proc_lib:start_link(?MODULE, init, [Xsize,Ysize]).

%% User API.

size() ->
    [{size,X,Y}] = ets:lookup(region, size),
    {X,Y}.

%% size() -> call(size).

valid_x(X) ->
    {Xsize,_} = size(),
    (X > 1) andalso (X < Xsize-1).

valid_y(Y) ->
    {_,Ysize} = size(),
    (Y > 1) andalso (Y < Ysize-1).
        
sector(X, Y) -> {trunc(X),trunc(Y)}.

get_sector(X, Y) ->
    call({get_sector,X,Y}).

add_sector(X, Y, What) ->
    call({add_sector,X,Y,What}).

rem_sector(X, Y, What) ->
    call({rem_sector,X,Y,What}).

find_unit(S) ->
    call({find_unit,S}).


%% init nonsense integration trying to test_me passing self, here we identify
%% that current S means U, lol basically that we're still refering to Ships
%% from the original World Simulator, if this observation is correct we need
%% to change it to U now that we are using Units in our abstractions.

test_me() -> test_me(self()).

test_me(S) ->
    cast({test_me,S}).

%% also could this be the way that we tale control of the processes state?
%% like receive from erlang the pid assigned by the BEAM to the lua VM?


del_unit() -> del_unit(self()).

del_unit(S) ->
    cast({del_unit,S}).

%% Internal protocol functions.

cast(Message) ->
    region ! {cast,self(),Message},
    ok.

call(Message) ->
    U = whereis(region),
    U ! {call,self(),Message},
    receive
    {reply,U,Rep} -> Rep
    end.

reply(To, Rep) ->
    To ! {reply,self(),Rep}.

%% Initialise it all.

init(Xsize, Ysize) ->
    register(region, self()),
    %% Create the region.
    ets:new(region, [named_table,duplicate_bag,protected]),
    ets:insert(region, {size,Xsize,Ysize}),
    State = #state{xsize=Xsize,ysize=Ysize},
    proc_lib:init_ack({ok,self()}),
    loop(State).

%% Main loop.

loop(State) ->
    receive
    {call,From,size} ->
        #state{xsize=Xsize,ysize=Ysize} = State,
        reply(From, {Xsize,Ysize}),
        loop(State);
    {call,From,{get_sector,X,Y}} ->
        Sector = sector(X, Y),
        reply(From, ets:lookup(region, Sector)),
        loop(State);
    {call,From,{add_sector,X,Y,What}} ->
        Sector = sector(X, Y),
        reply(From, ets:insert(region, {Sector,What})),
        loop(State);
    {call,From,{rem_sector,X,Y,What}} ->
        Sector = sector(X, Y),
        reply(From, ets:delete_object(region, {Sector,What})),
        loop(State);
    {call,From,{find_unit,S}} ->
        reply(From, ets:select(region, [{{'$1',S},[],['$1']}])),
        loop(State);
    {cast,From,{test_me,S}} ->

        lager:warning("Yo this S just test in here ~p \n", [S]),
        reply(From, {ok, S}),

        loop(State);
    {cast,From,{del_unit,S}} ->
        reply(From, ets:delete_object(region, {'_',S})),
        loop(State)
    end.