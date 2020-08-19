-module(map).

-export([start/2,start_link/2]).
-export([init/2]).
-export([sector/2,get_sector/2,add_sector/3,rem_sector/3]).
-export([size/0,valid_x/1,valid_y/1]).
-export([find_unit/1,del_unit/0,del_unit/1]).

%% Server state.
-record(st, {xsize,ysize}).

%% Management API.

start(Xsize, Ysize) ->
    proc_lib:start(?MODULE, init, [Xsize,Ysize]).

start_link(Xsize, Ysize) ->
    proc_lib:start_link(?MODULE, init, [Xsize,Ysize]).

%% User API.

size() ->
    [{size,X,Y}] = ets:lookup(map, size),
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

find_unit(U) ->
    call({find_unit,U}).

del_unit() -> del_unit(self()).

del_unit(U) ->
    cast({del_unit,U}).

%% Internal protocol functions.

cast(Msg) ->
    map ! {cast,self(),Msg},
    ok.

call(Msg) ->
    U = whereis(map),
    U ! {call,self(),Msg},
    receive
	{reply,U,Rep} -> Rep
    end.

reply(To, Rep) ->
    To ! {reply,self(),Rep}.

%% Initialise it all.

init(Xsize, Ysize) ->
    register(map, self()),
    %% Create the map.
    ets:new(map, [named_table,duplicate_bag,protected]),
    ets:insert(map, {size,Xsize,Ysize}),
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
	    reply(From, ets:lookup(map, Sector)),
	    loop(St);
	{call,From,{add_sector,X,Y,What}} ->
	    Sector = sector(X, Y),
	    reply(From, ets:insert(map, {Sector,What})),
	    loop(St);
	{call,From,{rem_sector,X,Y,What}} ->
	    Sector = sector(X, Y),
	    reply(From, ets:delete_object(map, {Sector,What})),
	    loop(St);
	{call,From,{find_unit,U}} ->
	    reply(From, ets:select(map, [{{'$1',U},[],['$1']}])),
	    loop(St);
	{cast,From,{del_unit,U}} ->
	    reply(From, ets:delete_object(map, {'_',U})),
	    loop(St)
    end.
