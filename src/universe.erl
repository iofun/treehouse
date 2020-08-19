-module(universe).

-export([start/2,start_link/2]).
-export([init/2]).
-export([sector/2,get_sector/2,add_sector/3,rem_sector/3]).
-export([size/0,valid_x/1,valid_y/1]).
-export([find_ship/1,del_ship/0,del_ship/1]).

%% Server state.
-record(st, {xsize,ysize}).

%% Management API.

start(Xsize, Ysize) ->
    proc_lib:start(?MODULE, init, [Xsize,Ysize]).

start_link(Xsize, Ysize) ->
    proc_lib:start_link(?MODULE, init, [Xsize,Ysize]).

%% User API.

size() ->
    [{size,X,Y}] = ets:lookup(universe, size),
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

find_ship(S) ->
    call({find_ship,S}).

del_ship() -> del_ship(self()).

del_ship(S) ->
    cast({del_ship,S}).

%% Internal protocol functions.

cast(Msg) ->
    universe ! {cast,self(),Msg},
    ok.

call(Msg) ->
    U = whereis(universe),
    U ! {call,self(),Msg},
    receive
	{reply,U,Rep} -> Rep
    end.

reply(To, Rep) ->
    To ! {reply,self(),Rep}.

%% Initialise it all.

init(Xsize, Ysize) ->
    register(universe, self()),
    %% Create the universe.
    ets:new(universe, [named_table,duplicate_bag,protected]),
    ets:insert(universe, {size,Xsize,Ysize}),
    St = #st{xsize=Xsize,ysize=Ysize},
    proc_lib:init_ack({ok,self()}),
    loop(St).

%% Main loop.

loop(St) ->
    receive
	{call,From,size} ->
	    #st{xsize=Xsize,ysize=Ysize} = St,
	    reply(From, {Xsize,Ysize}),
	    loop(St);
	{call,From,{get_sector,X,Y}} ->
	    Sector = sector(X, Y),
	    reply(From, ets:lookup(universe, Sector)),
	    loop(St);
	{call,From,{add_sector,X,Y,What}} ->
	    Sector = sector(X, Y),
	    reply(From, ets:insert(universe, {Sector,What})),
	    loop(St);
	{call,From,{rem_sector,X,Y,What}} ->
	    Sector = sector(X, Y),
	    reply(From, ets:delete_object(universe, {Sector,What})),
	    loop(St);
	{call,From,{find_ship,S}} ->
	    reply(From, ets:select(universe, [{{'$1',S},[],['$1']}])),
	    loop(St);
	{cast,From,{del_ship,S}} ->
	    reply(From, ets:delete_object(universe, {'_',S})),
	    loop(St)
    end.
