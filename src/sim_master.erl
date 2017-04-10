-module(sim_master).

-behaviour(gen_server).

%% User API.
-export([start/3,start_link/3,stop/1]).
-export([start_run/1,start_run/2,stop_run/0,stop_run/1]).
-export([get_ship/1,get_ship/2]).

%% Behaviour callbacks.
-export([init/1,terminate/2,handle_call/3,handle_cast/2,
	 handle_info/2,code_change/3]).

%% Test functions.
-export([init_lua/0,load/3]).

-record(st, {xsize,ysize,n,arr,tick=infinity,st}).

%% Management API.

start(Xsize, Ysize, N) ->
    gen_server:start({local,sim_master}, ?MODULE, {Xsize,Ysize,N}, []).

start_link(Xsize, Ysize, N) ->
    gen_server:start_link({local,sim_master}, ?MODULE, {Xsize,Ysize,N}, []).

stop(Pid) ->
    gen_server:call(Pid, stop).

%% User API.

start_run(Tick) ->
    gen_server:call(sim_master, {start_run,Tick}).

start_run(Sim, Tick) ->
    gen_server:call(Sim, {start_run,Tick}).

stop_run() ->
    gen_server:call(sim_master, stop_run).

stop_run(Sim) ->
    gen_server:call(Sim, stop_run).

get_ship(I) ->
    gen_server:call(sim_master, {get_ship,I}).

get_ship(Sim, I) ->
    gen_server:call(Sim, {get_ship,I}).

%% Behaviour callbacks.

init({Xsize,Ysize,N}) ->
    process_flag(trap_exit, true),
    {ok,_} = esdl_server:start_link(Xsize, Ysize),
    {ok,_} = sim_renderer:start_link(Xsize, Ysize),
    {ok,_} = universe:start_link(Xsize, Ysize),	%Start the universe
    random:seed(now()),				%Seed the RNG
    Arr = ets:new(sim_ship_array, [named_table,protected]),
    St = init_lua(),				%Get the Lua state
    lists:foreach(fun (I) ->
			  {ok,S} = start_ship(I, Xsize, Ysize, St),
			  ets:insert(Arr, {I,S})
		  end, lists:seq(1, N)),
    {ok,#st{xsize=Xsize,ysize=Ysize,n=N,arr=Arr,st=St}}.

%% init_lua() -> LuaState.
%%  Initialise a LuaState to be used for each ship process.

init_lua() ->
    L0 = luerl:init(),
    L1 = lists:foldl(fun({Name,Mod}, L) -> load([Name], Mod, L) end, L0,
		     [
              {esdl_server,luerl_esdl_server},
		      {universe,luerl_universe},
		      {ship,luerl_ship}]),
    %% Set the default ship.
    {_,L2} = luerl:do("this_ship = require 'default_ship'", L1),
    L2.

load(Key, Module, St0) ->
    {Lk,St1} = luerl:encode_list(Key, St0),
    {T,St2} = Module:install(St1),
    luerl:set_table1(Lk, T, St2).

start_ship(I, Xsize, Ysize, St) ->
    if I rem 8 =:= 0 ->
        io:format("unit type node~n");
       I rem 1 =:= 0 ->
        io:format("unit type imp~n")
    end,
    io:format("spawn imp ~p \n",[I]),
    %% Spread out the ships over the whole space.
    X = random:uniform(Xsize) - 1,
    Y = random:uniform(Ysize) - 1,
    {ok,S} = ship:start_link(X, Y, St),
    %% Random speeds from -0.25 to 0.25 sectors per tick (very fast).
    Dx = 2.5*random:uniform() - 1.25,
    Dy = 2.5*random:uniform() - 1.25,
    ship:set_speed(S, Dx, Dy),
    {ok,S}.

terminate(_, #st{}) -> ok.

handle_call({start_run,Tick}, _, #st{arr=Arr}=St) ->
    %% We don't need the Acc here, but there is no foreach.
    Start = fun ({_,S}, Acc) -> ship:set_tick(S, Tick), Acc end,
    ets:foldl(Start, ok, Arr),
    {reply,ok,St#st{tick=Tick}};
handle_call(stop_run, _, #st{arr=Arr}=St) ->
    %% We don't need the Acc here, but there is no foreach.
    Stop = fun ({_,S}, Acc) -> ship:set_tick(S, infinity), Acc end,
    ets:foldl(Stop, ok, Arr),
    {reply,ok,St#st{tick=infinity}};
handle_call({get_ship,I}, _, #st{arr=Arr}=St) ->
    case ets:lookup(Arr, I) of
	[] -> {reply,error,St};
	[{I,S}] -> {reply,{ok,S},St}
    end;
handle_call(stop, _, St) ->
    %% Do everything in terminate.
    {stop,normal,ok,St}.

handle_info({'EXIT',S,E}, #st{arr=Arr}=St) ->
    io:format("~p died: ~p\n", [S,E]),
    ets:match_delete(Arr, {'_',S}),		%Remove the ship
    {noreply,St};
handle_info(_, St) -> {noreply,St}.

%% Unused callbacks.
handle_cast(_, St) -> {noreply,St}.

code_change(_, St, _) -> {ok,St}.