-module(tree_master).
-behaviour(gen_server).

%% API.
-export([start_link/0]).

%% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-record(state, {
}).

%% API.

-spec start_link() -> {ok, pid()}.
start_link() ->
	gen_server:start_link(?MODULE, [], []).

%% gen_server.

init([]) ->
	process_flag(trap_exit, true),
	LuaState = init_lua(),
	{ok, _} = sub_bind:start_link(),
	{ok, #state{state=LuaState}}.

%% init_lua() -> LuaState.
%% Initialise a LuaState to be used for each imp process.

init_lua() ->
	Lua0 = luerl:init(),
	Lua1 = lists:foldl(fun({Name,Mod}, L) -> load([Name], Mod, L) end, Lua0,
		[{tree_dht,luerl_dht,
		  tree_sub,luerl_sub}]),
	%% Set the default imp
	{_,Lua2} = luerl:do("this_imp = require 'default_imp'", Lua1),
	Lua2.

load(Key, Module, State0) ->
	{Lk,State1} = luerl:encode_list(Key, State0),
	{T,State2} = Module:install(State1),
	luerl:set_table1(Lk, T, State2).


handle_call(_Request, _From, State) ->
	{reply, ignored, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
