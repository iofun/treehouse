-module(esdl_server).

-export([start_link/2,start/2]).
-export([init/2]).
-export([add_unit/0,del_unit/0,set_unit/4]).

%% Server state.
-record(st, {w,r,tab}).

%% Management API.

start(Xsize, Ysize) ->
    proc_lib:start(?MODULE, init, [Xsize,Ysize]).

start_link(Xsize, Ysize) ->
    proc_lib:start_link(?MODULE, init, [Xsize,Ysize]).

%% User API.

add_unit() ->
    call(add_unit).

del_unit() ->
    call(del_unit).

set_unit(Style, Col, X, Y) ->
    Sec = map:sector(X, Y),		%Which sector?
    cast({set_unit,Style,Col,Sec}).

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
    T = ets:new(esdl_unit_array, [named_table,protected]),
    proc_lib:init_ack({ok,self()}),
    loop(#st{tab=T}).

loop(St) ->
    receive
	{call,From,add_unit} ->
	    ets:insert(St#st.tab, {From,null,null,null}),
	    reply(From, ok),
	    loop(St);
	{call,From,del_unit} ->
	    ets:delete(St#st.tab, From),
	    reply(From, ok),
	    loop(St);
	{cast,From,{set_unit,Style,Col,Sector}} ->
	    ets:insert(St#st.tab, {From,Style,Col,Sector}),
	    loop(St)
    end.
