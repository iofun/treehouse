-module(esdl_server).

-export([start_link/2,start/2]).
-export([init/2]).
-export([add_ship/0,del_ship/0,set_ship/4]).

%% Server state.
-record(st, {w,r,tab}).

%% Management API.

start(Xsize, Ysize) ->
    proc_lib:start(?MODULE, init, [Xsize,Ysize]).

start_link(Xsize, Ysize) ->
    proc_lib:start_link(?MODULE, init, [Xsize,Ysize]).

%% User API.

add_ship() ->
    call(add_ship).

del_ship() ->
    call(del_ship).

set_ship(Style, Col, X, Y) ->
    Sec = universe:sector(X, Y),		%Which sector?
    cast({set_ship,Style,Col,Sec}).

%% Internal protocol functions.

cast(Msg) ->
    esdl_server ! {cast,self(),Msg},
    ok.

call(Msg) ->
    U = whereis(esdl_server),
    U ! {call,self(),Msg},
    receive
	{reply,U,Rep} -> Rep
    end.

reply(To, Rep) ->
    To ! {reply,self(),Rep}.

%% Initialise it all.

init(Xsize, Ysize) ->
    register(esdl_server, self()),
    T = ets:new(esdl_ship_array, [named_table,protected]),
    proc_lib:init_ack({ok,self()}),
    loop(#st{tab=T}).

loop(St) ->
    receive
	{call,From,add_ship} ->
	    ets:insert(St#st.tab, {From,null,null,null}),
	    reply(From, ok),
	    loop(St);
	{call,From,del_ship} ->
	    ets:delete(St#st.tab, From),
	    reply(From, ok),
	    loop(St);
	{cast,From,{set_ship,Style,Col,Sector}} ->
	    ets:insert(St#st.tab, {From,Style,Col,Sector}),
	    loop(St)
    end.
