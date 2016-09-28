-module(tree_dht_c).

-export([start_link/0,start/0,stop/0]).
-export([init/0]).
-export([send_hash_c/1]).

%% Management API.

start() ->
    proc_lib:start(?MODULE, init, []).

start_link() ->
    proc_lib:start_link(?MODULE, init, []).

stop() ->
    cast(stop).

%% Server state.

-record(state, {}).

%% User API.

send_hash_c(Message) ->
    cast({send_hash_c,Message}).


%% Internal protocol functions.

cast(Message) ->
    hash_c_server ! {cast,self(),Message},
    ok.

%% Initialise it all.

init() ->
    application:load(dht),
    application:set_env(dht, port, 1731),
    application:ensure_all_started(dht),
    %% now node c and b join node a
    dht:ping({{127, 0, 0, 1}, 1729}),
    Selx = dht:lookup(456),
    io:format("~p~n",[Selx]),
    % Val = "Carepetch",
    % ID = crypto:hash(sha, Val),
    register(hash_c_server, self()),
    proc_lib:init_ack({ok,self()}),
    loop(#state{}).

loop(State) ->
    receive
        {cast,From,{send_hash_c,Message}} ->
            io:format("~w: ~p\n", [From,Message]),
            loop(State);
        {cast,_From,stop} ->            %We're done
            ok;
        _ ->                            %Ignore everything else
            loop(State)
    end.