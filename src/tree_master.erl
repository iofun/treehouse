-module(tree_master).
-behaviour(gen_server).

%% API.
-export([start_link/0]).
-export([new_sim/3, sim_run/1, sim_run/2]).
-export([sim_stop/1, sim_stop/2, stop_all/0]).
-export([get_unit/1, get_unit/2]).

%% gen_server behavior callbacks.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

%% Test functions.
-export([init_lua/0,load/3]).
-record(state, {xsize,ysize,n,array,tick=infinity,state}).

%% Process defined API.

-spec start_link() -> {ok, pid()}.
start_link() ->
	gen_server:start_link(?MODULE, [], []).

%% User API.

new_sim({Xsize,Ysize,N}) ->
	{ok,_} region:start_link(Xsize,Ysize), %Start the region
	random:seed(now()),	% Seed the RNG
	Array = ets:new(sim_unit_array, [named_table,protected]),
	State = init_lua(),
	lists:foreach(fun (I) ->
			  {ok,S} = start_ship(I, Xsize, Ysize, State),
			  ets:insert(Array, {I,S})
		  end, lists:seq(1, N)),
    {ok,#state{xsize=Xsize,ysize=Ysize,n=N,array=Array,state=State}}.

sim_run(Tick) ->
    gen_server:call(sim_master, {start_run,Tick}).

sim_run(Sim, Tick) ->
    gen_server:call(Sim, {start_run,Tick}).

sim_stop() ->
    gen_server:call(sim_master, stop_run).

sim_stop(Sim) ->
    gen_server:call(Sim, sim_stop).

get_ship(I) ->
    gen_server:call(sim_master, {get_ship,I}).

get_ship(Sim, I) ->
    gen_server:call(Sim, {get_ship,I}).

%% gen_server.
init([]) ->
	process_flag(trap_exit, true),
	{ok, _} = sub_bind:start_link(),
	{ok, _} = tree_dht_a:start_link(),
	{ok, _} = tree_dht_b:start_link(),
	{ok, _} = tree_dht_c:start_link(),
	{ok, #state{}}.

%% Behavior callbacks.

init_lua() ->
    L0 = luerl:init(),
    L1 = lists:foldl(fun({Name,Mod}, L) -> load([Name], Mod, L) end, L0,
		     [
		      {region,luerl_region},
		      {unit,luerl_unit}]),
    %% Set the default unit behavior.
    {_,L2} = luerl:do("this_unit = require 'default_unit'", L1),
    L2.

load(Key, Module, State0) ->
    {Lk,State1} = luerl:encode_list(Key, State0),
    {T,State2} = Module:install(State1),
    luerl:set_table1(Lk, T, State2).

start_unit(I, Xsize, Ysize, St) ->
    if I rem 8 =:= 0 ->
        io:format("unit type node~n");
       I rem 1 =:= 0 ->
        io:format("unit type imp~n")
    end,
    io:format("spawn unit ~p \n",[I]),
    %% Spread out the units over the whole space.
    X = random:uniform(Xsize) - 1,
    Y = random:uniform(Ysize) - 1,
    {ok,S} = unit:start_link(X, Y, St),
    %% Random speeds from -0.25 to 0.25 sectors per tick (very fast).
    Dx = 2.5*random:uniform() - 1.25,
    Dy = 2.5*random:uniform() - 1.25,
    unit:set_speed(S, Dx, Dy),
    {ok,S}.

handle_call({start_run,Tick}, _, #st{array=Array}=State) ->
    %% We don't need the Acc here, but there is no foreach.
    Start = fun ({_,S}, Acc) -> ship:set_tick(S, Tick), Acc end,
    ets:foldl(Start, ok, Arr),
    {reply,ok,St#st{tick=Tick}};
handle_call(stop_run, _, #st{array=Array}=State) ->
    %% We don't need the Acc here, but there is no foreach.
    Stop = fun ({_,S}, Acc) -> ship:set_tick(S, infinity), Acc end,
    ets:foldl(Stop, ok, Arr),
    {reply,ok,St#st{tick=infinity}};
handle_call({get_ship,I}, _, #st{array=Array}=State) ->
    case ets:lookup(Arr, I) of
	[] -> {reply,error,State};
	[{I,S}] -> {reply,{ok,S},St}
    end;
handle_call(stop, _, State) ->
    %% Do everything in terminate.
    {stop,normal,ok,State}.

handle_info({'EXIT',S,E}, #st{array=Array}=State) ->
    io:format("~p died: ~p\n", [S,E]),
    ets:match_delete(Array, {'_',S}),		%Remove the ship
    {noreply,State};
handle_info(_, State) -> {noreply,State}.

%% Unused callbacks.

handle_call(_Request, _From, State) ->
	{reply, ignored, State}.

handle_cast(_Message, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.