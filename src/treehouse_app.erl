-module(treehouse_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
        {'_', [
    		%% hello space cowboy
        	{"/", hello_handler, []},
        	{"/imps/", imps_handler, []}
        ]}
    ]),
    cowboy:start_http(treehouse_http_listener, 100, [{port, 8215}],
        [{env, [{dispatch, Dispatch}]}]
    ),
    tree_master:start_link(),
	treehouse_sup:start_link().

stop(_State) ->
	ok.
