-module(sim_sound).

-export([start_link/0,start/0,stop/0]).
-export([init/0]).
-export([make_sound/1]).

%% Management API.

start() ->
    proc_lib:start(?MODULE, init, []).

start_link() ->
    proc_lib:start_link(?MODULE, init, []).

stop() ->
    cast(stop).

%% Server state.
-record(st, {}).

%% User API.

make_sound(Sound) ->
    cast({make_sound,Sound}).

%% Internal protocol functions.

cast(Msg) ->
    sound_server ! {cast,self(),Msg},
    ok.

%% Initialise it all.

init() ->
    register(sound_server, self()),
    proc_lib:init_ack({ok,self()}),
    loop(#st{}).

loop(St) ->
    receive
	{cast,From,{make_sound,Sound}} ->
	    io:format("~w: ~p\n", [From,Sound]),
	    loop(St);
	{cast,_From,stop} ->			%We're done
	    ok;
	_ ->					%Ignore everything else
	    loop(St)
    end.
