-module(sub_bind).

-export([start_link/0,start/0,stop/0]).
-export([init/0]).
-export([send_message/1]).

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

send_message(Message) ->
    cast({send_message,Message}).

%% Internal protocol functions.

cast(Message) ->
    sub_server ! {cast,self(),Message},
    ok.

%% Initialise it all.

init() ->
    application:ensure_all_started(chumak),
    % Val = "Carepetch",
    % ID = crypto:hash(sha, Val),
    register(sub_server, self()),
    proc_lib:init_ack({ok,self()}),
    loop(#state{}).

loop(State) ->
    receive
        {cast,From,{send_message,Message}} ->
            io:format("~w: ~p\n", [From,Message]),
            loop(State);
        {cast,_From,stop} ->            %We're done
            ok;
        _ ->                            %Ignore everything else
            loop(State)
    end.