-module(sim_master).

-behaviour(gen_server).

%% User API.
-export([start/3,start_link/3,stop/1]).
-export([start_run/1,start_run/2,stop_run/0,stop_run/1]).
-export([get_unit/1,get_unit/2]).

%% Behaviour callbacks.
-export([init/1,terminate/2,handle_call/3,handle_cast/2,
	 handle_info/2,code_change/3]).

%% Test functions.
-export([init_lua/0,load/3]).

-record(state, {xsize,ysize,n,array,tick=infinity,state}).

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

get_unit(I) ->
    gen_server:call(sim_master, {get_unit,I}).

get_unit(Sim, I) ->
    gen_server:call(Sim, {get_unit,I}).

%% Behaviour callbacks.

init({Xsize,Ysize,N}) ->
    process_flag(trap_exit, true),
    {ok,_} = region:start_link(Xsize, Ysize),	%Start the region
    random:seed(now()),				%Seed the RNG
    Array = ets:new(sim_unit_array, [named_table,protected]),
    State = init_lua(),				%Get the Lua state
    lists:foreach(fun (I) ->
			  {ok,S} = start_unit(I, Xsize, Ysize, State),
			  ets:insert(Array, {I,S})
		  end, lists:seq(1, N)),
    {ok,#state{xsize=Xsize,ysize=Ysize,n=N,array=Array,state=State}}.

%% init_lua() -> LuaState.
%%  Initialise a LuaState to be used for each unit process.

init_lua() ->
    L0 = luerl:init(),
    L1 = lists:foldl(fun({Name,Mod}, L) -> load([Name], Mod, L) end, L0,
		     [
		      {region,luerl_region},
		      {unit,luerl_unit}]),
    %% Set the default unit.
    {_,L2} = luerl:do("this_unit = require 'default'", L1),
    L2.

load(Key, Module, State0) ->
    {Lk,State1} = luerl:encode_list(Key, State0),
    {T,State2} = Module:install(State1),
    luerl:set_table1(Lk, T, State2).

start_unit(I, Xsize, Ysize, State) ->
    if I rem 8 =:= 0 ->
        io:format("unit type node~n");
       I rem 1 =:= 0 ->
        io:format("unit type imp~n")
    end,
    io:format("spawn unit ~p \n",[I]),
    %% Spread out the units over the whole space.
    X = random:uniform(Xsize) - 1,
    Y = random:uniform(Ysize) - 1,
    {ok,S} = unit:start_link(X, Y, State),
    %% Random speeds from -0.25 to 0.25 sectors per tick (very fast).
    Dx = 2.5*random:uniform() - 1.25,
    Dy = 2.5*random:uniform() - 1.25,
    unit:set_speed(S, Dx, Dy),
    {ok,S}.

terminate(_, #state{}) -> ok.

handle_call({start_run,Tick}, _, #state{array=Array}=State) ->
    %% We don't need the Acc here, but there is no foreach.
    Start = fun ({_,S}, Acc) -> unit:set_tick(S, Tick), Acc end,
    ets:foldl(Start, ok, Array),
    {reply,ok,State#state{tick=Tick}};
handle_call(stop_run, _, #state{array=Array}=State) ->
    %% We don't need the Acc here, but there is no foreach.
    Stop = fun ({_,S}, Acc) -> unit:set_tick(S, infinity), Acc end,
    ets:foldl(Stop, ok, Array),
    {reply,ok,State#state{tick=infinity}};
handle_call({get_unit,I}, _, #state{array=Array}=State) ->
    case ets:lookup(Array, I) of
	[] -> {reply,error,State};
	[{I,S}] -> {reply,{ok,S},State}
    end;
handle_call(stop, _, State) ->
    %% Do everything in terminate.
    {stop,normal,ok,State}.

handle_info({'EXIT',S,E}, #state{array=Array}=State) ->
    io:format("~p died: ~p\n", [S,E]),
    ets:match_delete(Array, {'_',S}),		%Remove the unit
    {noreply,State};
handle_info(_, State) -> {noreply,State}.

%% Unused callbacks.
handle_cast(_, State) -> {noreply,State}.

code_change(_, State, _) -> {ok,State}.